package com.nearnow.product;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

public class ProductIdsResponse {
    @JsonProperty("product_ids")
    private List<Long> productIds;
    public List<Long> getProductIds() { return productIds; }
    public void setProductIds(List<Long> productIds) { this.productIds = productIds; }
}
