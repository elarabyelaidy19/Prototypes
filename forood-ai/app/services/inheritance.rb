# Inheritance Module — وحدة المواريث
# Root namespace for the Islamic inheritance (Faraid / فرائض) calculator.
# Defines shared types and helper predicates used across all service classes.
module Inheritance
  # HeirShare — نصيب الوارث
  # Represents a single heir's calculated share with all display data.
  HeirShare = Struct.new(
    :heir_type, :count, :total_share, :per_person_share,
    :total_amount, :per_person_amount,
    :label_ar, :label_en, :reason_ar,
    keyword_init: true
  )

  # Result — نتيجة الحساب
  # Final output of the calculator containing all shares, adjustments, and debug info.
  Result = Struct.new(
    :heir_shares, :base_denominator, :adjusted_denominator,
    :awl_applied, :radd_applied, :estate_amount, :blocked_heirs,
    :debug_info,
    keyword_init: true
  )

  # HeirHelpers — مساعدات التحقق من الورثة
  # Shared predicates for checking heir presence, used by Blocker and ShareComputer.
  module HeirHelpers
    private

    # Returns the count of a specific heir type, defaulting to 0.
    # عدد الورثة من نوع معين، الافتراضي صفر
    def heir_count(heirs, type)
      heirs.fetch(type, 0)
    end

    # Checks if any descendant (son, daughter, grandson, granddaughter) is present.
    # هل يوجد فرع وارث (ابن، بنت، ابن ابن، بنت ابن)؟
    def descendants_present?(heirs)
      %i[son daughter sons_son sons_daughter].any? { |k| heir_count(heirs, k) > 0 }
    end

    # Checks if any male descendant (son or grandson) is present.
    # هل يوجد فرع وارث ذكر (ابن أو ابن ابن)؟
    def male_descendants_present?(heirs)
      %i[son sons_son].any? { |k| heir_count(heirs, k) > 0 }
    end

    # Checks if only female descendants exist (daughters/granddaughters but no sons/grandsons).
    # هل الفرع الوارث إناث فقط (بنات أو بنات ابن بدون أبناء)؟
    def only_female_descendants?(heirs)
      descendants_present?(heirs) && !male_descendants_present?(heirs)
    end
  end
end
