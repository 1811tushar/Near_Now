package com.nearnow.vendor;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;

import java.util.List;

public class GenerateProductDescriptionRequestDTO {

    @NotBlank
    @Size(max = 200)
    @JsonProperty("product_name")
    private String productName;

    @NotBlank
    @Size(max = 100)
    private String category;

    @NotEmpty
    @Size(max = 12)
    @JsonProperty("bullet_points")
    private List<@NotBlank @Size(max = 500) String> bulletPoints;

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public List<String> getBulletPoints() { return bulletPoints; }
    public void setBulletPoints(List<String> bulletPoints) { this.bulletPoints = bulletPoints; }
}
