package com.nearnow.ai.automation;

import com.nearnow.ai.AiServiceClient;
import com.nearnow.notification.NotificationService;
import com.nearnow.order.OrderRepository;
import com.nearnow.order.OrderStatus;
import com.nearnow.vendor.PurchaseOrderRepository;
import com.nearnow.vendor.PurchaseOrderStatus;
import com.nearnow.vendor.Vendor;
import com.nearnow.vendor.VendorRepository;
import com.nearnow.warehouse.PickListRepository;
import com.nearnow.warehouse.WarehouseService;
import com.nearnow.warehouse.StockLevel;
import com.nearnow.warehouse.StockLevelRepository;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.DayOfWeek;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.List;

@Service
public class AiAutomationScheduler {

    private static final ZoneId ZONE = ZoneId.of("Asia/Kolkata");

    private final VendorRepository vendorRepository;
    private final PurchaseOrderRepository purchaseOrderRepository;
    private final OrderRepository orderRepository;
    private final StockLevelRepository stockLevelRepository;
    private final PickListRepository pickListRepository;
    private final AiServiceClient aiServiceClient;
    private final NotificationService notificationService;
    private final WarehouseService warehouseService;

    public AiAutomationScheduler(VendorRepository vendorRepository,
                                  PurchaseOrderRepository purchaseOrderRepository,
                                  OrderRepository orderRepository,
                                  StockLevelRepository stockLevelRepository,
                                  PickListRepository pickListRepository,
                                  AiServiceClient aiServiceClient,
                                  NotificationService notificationService,
                                  WarehouseService warehouseService) {
        this.vendorRepository = vendorRepository;
        this.purchaseOrderRepository = purchaseOrderRepository;
        this.orderRepository = orderRepository;
        this.stockLevelRepository = stockLevelRepository;
        this.pickListRepository = pickListRepository;
        this.aiServiceClient = aiServiceClient;
        this.notificationService = notificationService;
        this.warehouseService = warehouseService;
    }

    @Scheduled(cron = "0 0 8 ? * MON", zone = "Asia/Kolkata")
    public void weeklyVendorReports() {
        LocalDate thisMonday = LocalDate.now(ZONE).with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDate weekStart = thisMonday.minusWeeks(1);
        LocalDate weekEnd = thisMonday.minusDays(1);
        Instant start = weekStart.atStartOfDay(ZONE).toInstant();
        Instant endExclusive = thisMonday.atStartOfDay(ZONE).toInstant();

        for (Vendor vendor : vendorRepository.findAllWithUser()) {
            long orders = orderRepository.countDistinctOrdersContainingVendorAndCreatedAtBetween(
                    vendor.getId(), start, endExclusive);
            long fulfilled = orderRepository.countDistinctOrdersContainingVendorAndStatusAndCreatedAtBetween(
                    vendor.getId(), OrderStatus.DELIVERED, start, endExclusive);
            long cancelled = orderRepository.countDistinctOrdersContainingVendorAndStatusAndCreatedAtBetween(
                    vendor.getId(), OrderStatus.CANCELLED, start, endExclusive);

            VendorWeeklyStats stats = new VendorWeeklyStats(
                    vendor.getId(), vendor.getBusinessName(), weekStart.toString(), weekEnd.toString(),
                    orders, fulfilled, cancelled,
                    purchaseOrderRepository.countByVendorIdAndCreatedAtBetween(vendor.getId(), start, endExclusive),
                    purchaseOrderRepository.countByVendorIdAndStatusAndCreatedAtBetween(vendor.getId(), PurchaseOrderStatus.ACCEPTED, start, endExclusive),
                    purchaseOrderRepository.countByVendorIdAndStatusAndCreatedAtBetween(vendor.getId(), PurchaseOrderStatus.DISPATCHED, start, endExclusive),
                    purchaseOrderRepository.countByVendorIdAndStatusAndCreatedAtBetween(vendor.getId(), PurchaseOrderStatus.RECEIVED, start, endExclusive),
                    purchaseOrderRepository.countByVendorIdAndStatusAndCreatedAtBetween(vendor.getId(), PurchaseOrderStatus.REJECTED, start, endExclusive)
            );

            try {
                String summary = aiServiceClient.summarizeVendorReport(stats);
                notificationService.sendVendorWeeklyReport(vendor.getUser().getEmail(), vendor.getBusinessName(), weekStart, weekEnd, summary);
            } catch (Exception e) {
                // One vendor failing must not prevent the remaining weekly reports.
                org.slf4j.LoggerFactory.getLogger(getClass()).error(
                        "Vendor weekly report failed for vendor #{}", vendor.getId(), e);
            }
        }
    }

    @Scheduled(cron = "0 30 2 * * *", zone = "Asia/Kolkata")
    public void nightlyDemandForecast() {
        Instant since = LocalDate.now(ZONE).minusDays(90).atStartOfDay(ZONE).toInstant();
        List<DemandSeries> series = new ArrayList<>();

        for (StockLevel level : stockLevelRepository.findAllWithStoreAndProduct()) {
            List<DemandPoint> points = pickListRepository.findDailyDemand(
                            level.getStore().getId(), level.getProduct().getId(), since)
                    .stream()
                    .map(row -> new DemandPoint(row.getDay().toString(), row.getQuantity()))
                    .toList();
            series.add(new DemandSeries(
                    level.getStore().getId(), level.getProduct().getId(),
                    level.getQuantity(), level.getReorderThreshold(), points
            ));
        }

        if (series.isEmpty()) return;

        DemandForecastResponse response = aiServiceClient.forecast(
                new DemandForecastRequest(series, "moving_average", 7));

        if (response.suggestions() == null) return;

        // This deliberately calls the EXISTING threshold-setting service method.
        // It does not mutate StockLevel or duplicate the auto-PO logic here.
        for (ThresholdSuggestion suggestion : response.suggestions()) {
            if (suggestion.suggested_threshold() < 0) continue;
            // WarehouseService transaction remains the single threshold path.
            warehouseService.setReorderThreshold(
                    suggestion.store_id(), suggestion.product_id(), suggestion.suggested_threshold());
        }
    }

}
