package com.nearnow.warehouse;

import com.nearnow.product.Product;
import jakarta.persistence.*;

@Entity
@Table(name = "stock_levels", uniqueConstraints = {
        @UniqueConstraint(
                name = "uq_stock_level_store_product",
                columnNames = {"store_id", "product_id"}
        )
}, indexes = {
        @Index(name = "idx_stock_level_product", columnList = "product_id")
})
public class StockLevel {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "store_id", nullable = false)
    private Store store;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(nullable = false)
    private int quantity;

    // Admin-set trigger point for auto-restocking. 0 = auto-restock
    // disabled for this store+product (the default until an admin
    // explicitly sets one via the threshold endpoint).
    @Column(nullable = false)
    private int reorderThreshold = 0;

    protected StockLevel() {
    }

    public StockLevel(Store store, Product product, int quantity) {
        this.store = store;
        this.product = product;
        this.quantity = quantity;
    }

    public Long getId() { return id; }
    public Store getStore() { return store; }
    public Product getProduct() { return product; }
    public int getQuantity() { return quantity; }
    public int getReorderThreshold() { return reorderThreshold; }

    public void setQuantity(int quantity) { this.quantity = quantity; }
    public void setReorderThreshold(int reorderThreshold) { this.reorderThreshold = reorderThreshold; }
}
