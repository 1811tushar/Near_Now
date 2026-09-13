package com.nearnow.warehouse;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.time.Instant;

public interface PickListRepository extends JpaRepository<PickList, Long> {

    List<PickList> findByStoreIdOrderByIdDesc(Long storeId);

    Optional<PickList> findByOrderId(Long orderId);

    @Query("""
            select p
            from PickList p
            where p.id = :pickListId
              and p.store.warehouseManager.id = :managerId
            """)
    Optional<PickList> findOwnedByManager(
            @Param("pickListId") Long pickListId,
            @Param("managerId") Long managerId
    );

    @Query(value = """
            select pl.store_id as storeId, pli.product_id as productId,
                   cast(o.created_at as date) as day, sum(pli.quantity) as quantity
            from pick_lists pl
            join orders o on o.id = pl.order_id
            join pick_list_items pli on pli.pick_list_id = pl.id
            where pl.store_id = :storeId
              and pli.product_id = :productId
              and o.created_at >= :since
              and o.status <> 'CANCELLED'
            group by pl.store_id, pli.product_id, cast(o.created_at as date)
            order by day asc
            """, nativeQuery = true)
    List<com.nearnow.ai.automation.DailyDemandRow> findDailyDemand(
            @Param("storeId") Long storeId, @Param("productId") Long productId, @Param("since") Instant since);

}
