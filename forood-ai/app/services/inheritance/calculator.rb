# Inheritance::Calculator — حاسبة المواريث
# Main orchestrator for Islamic inheritance (Faraid / فرائض) calculations.
# Wires together: Validator → Blocker → ShareComputer → ResultBuilder.
#
# Usage / الاستخدام:
#   result = Inheritance::Calculator.new(
#     deceased_gender: :male,   # جنس المتوفى
#     estate_amount: 100_000,   # مبلغ التركة
#     heirs: { son: 2, wife: 1 } # الورثة وأعدادهم
#   ).calculate
module Inheritance
  class Calculator
    # Backward-compatible aliases for any external references
    HeirShare = Inheritance::HeirShare
    Result = Inheritance::Result

    def initialize(deceased_gender:, estate_amount:, heirs:)
      @deceased_gender = deceased_gender.to_sym
      @estate_amount = BigDecimal(estate_amount.to_s)
      @input_heirs = heirs.to_h.transform_keys(&:to_sym).transform_values(&:to_i).select { |_, v| v > 0 }
    end

    def calculate
      # Step 1: Validate input — التحقق من صحة المدخلات
      Validator.new(deceased_gender: @deceased_gender, heirs: @input_heirs).validate!

      # Step 2: Apply blocking rules — تطبيق قواعد الحجب
      blocker = Blocker.new(input_heirs: @input_heirs)
      active = blocker.apply_exclusion_rules(@input_heirs.dup)

      # Step 3: Compute shares for all heir types — حساب الأنصبة
      computer = ShareComputer.new(blocker: blocker, input_heirs: @input_heirs)
      computer.compute_all_shares(active)

      # Step 4: Safety net — purge any blocked heirs from computed shares
      # شبكة أمان — حذف أي وارث محجوب من الأنصبة
      blocker.purge_excluded_heirs_from_shares!(
        fixed: computer.fixed,
        reasons: computer.reasons,
        residuary: computer.residuary
      )

      # Step 5: Build final result with Awl/Radd adjustments — بناء النتيجة النهائية
      ResultBuilder.new(
        fixed: computer.fixed,
        reasons: computer.reasons,
        residuary: computer.residuary,
        blocked: blocker.blocked,
        input_heirs: @input_heirs,
        active_heirs: active,
        estate_amount: @estate_amount
      ).build_result
    end
  end
end
