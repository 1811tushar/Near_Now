package com.nearnow.ai.automation;

public record VendorOnboardingFields(
        String name,
        String id_number,
        String address,
        String date_of_birth,
        String document_type,
        String issuing_authority,
        String expiry_date
) {}
