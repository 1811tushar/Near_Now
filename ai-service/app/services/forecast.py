import numpy as np
import pandas as pd

from app.schemas.ai import DemandForecastRequest, DemandForecastResponse, ThresholdSuggestion


class ForecastService:
    @staticmethod
    def calculate(request: DemandForecastRequest) -> DemandForecastResponse:
        suggestions: list[ThresholdSuggestion] = []

        for series in request.series:
            if not series.daily_demand:
                continue

            frame = pd.DataFrame(
                [{"date": point.date, "quantity": point.quantity} for point in series.daily_demand]
            )
            frame["date"] = pd.to_datetime(frame["date"], errors="coerce")
            frame = frame.dropna(subset=["date"]).sort_values("date")
            if frame.empty:
                continue

            # Reindex to daily cadence so a zero-sales day is represented as zero demand.
            frame = frame.set_index("date").resample("D")["quantity"].sum().fillna(0.0)
            window = min(request.window, len(frame))
            if request.method == "exponential_smoothing" and len(frame) > 1:
                forecast = float(frame.ewm(span=window, adjust=False).mean().iloc[-1])
            else:
                forecast = float(frame.tail(window).mean())

            average = float(frame.mean())
            # Keep the threshold rule deterministic: cover 7 days of forecast demand.
            suggested = int(max(0, np.ceil(forecast * 7.0)))

            suggestions.append(
                ThresholdSuggestion(
                    store_id=series.store_id,
                    product_id=series.product_id,
                    suggested_threshold=suggested,
                    average_daily_demand=round(average, 4),
                    forecast_daily_demand=round(forecast, 4),
                )
            )

        return DemandForecastResponse(suggestions=suggestions)
