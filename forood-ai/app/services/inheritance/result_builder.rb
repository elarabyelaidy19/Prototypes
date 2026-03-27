# Inheritance::ResultBuilder — بناء النتيجة النهائية
# Assembles the final Result struct from computed shares.
# Handles three scenarios:
#   1. Normal — أنصبة عادية: fixed + residuary divide the estate exactly.
#   2. Awl (عول): total fixed shares > 1, all shares reduced proportionally.
#   3. Radd (رد): total fixed shares < 1 with no residuary, surplus redistributed.
module Inheritance
  class ResultBuilder
    include Constants

    def initialize(fixed:, reasons:, residuary:, blocked:,
                   input_heirs:, active_heirs:, estate_amount:)
      @fixed = fixed
      @reasons = reasons
      @residuary = residuary
      @blocked = blocked
      @input_heirs = input_heirs
      @active_heirs = active_heirs
      @estate_amount = estate_amount
    end

    # Builds the final Result struct with all heir shares and metadata.
    # بناء النتيجة النهائية مع جميع الأنصبة والبيانات الوصفية
    def build_result
      final_shares = {}
      awl = false
      radd = false

      total_fixed = @fixed.values.sum(Rational(0))

      base = calculate_base_denominator
      adjusted = base

      if @residuary.any?
        remainder = [Rational(1) - total_fixed, Rational(0)].max

        @fixed.each { |type, share| final_shares[type] = share }

        if remainder > 0
          total_weight = @residuary.sum { |r| r[:count] * r[:weight] }
          @residuary.each do |r|
            portion = remainder * Rational(r[:count] * r[:weight], total_weight)
            final_shares[r[:type]] = (final_shares[r[:type]] || Rational(0)) + portion
          end
        end

        if total_fixed > Rational(1)
          pure_residuary = @residuary.select { |r| !@fixed.key?(r[:type]) }

          if pure_residuary.empty?
            final_shares = {}
            @fixed.each { |type, share| final_shares[type] = share }
            awl = true
            adjusted = calculate_awl_adjusted_denominator(base)
            reduce_shares_proportionally!(final_shares, total_fixed)
          else
            total_all = final_shares.values.sum(Rational(0))
            final_shares.transform_values! { |s| s / total_all } if total_all > 0
          end
        end
      elsif total_fixed > Rational(1)
        # Awl — عول: proportional reduction when fixed shares exceed 1
        awl = true
        adjusted = calculate_awl_adjusted_denominator(base)
        @fixed.each { |type, share| final_shares[type] = share / total_fixed }
      elsif total_fixed < Rational(1)
        # Radd — رد: redistribute surplus to non-spouse fixed heirs
        radd = true
        @fixed.each { |type, share| final_shares[type] = share }
        redistribute_surplus_to_non_spouse!(final_shares)
      else
        @fixed.each { |type, share| final_shares[type] = share }
      end

      assemble_result_struct(final_shares, base, adjusted, awl, radd, total_fixed)
    end

    private

    # Assembles the Result struct from the final computed shares.
    # تجميع هيكل النتيجة من الأنصبة النهائية المحسوبة
    def assemble_result_struct(final_shares, base, adjusted, awl, radd, total_fixed)
      heir_results = final_shares.map do |type, share|
        count = @active_heirs[type] || @input_heirs[type] || 1
        per_person = share / count
        HeirShare.new(
          heir_type: type,
          count: count,
          total_share: share,
          per_person_share: per_person,
          total_amount: (@estate_amount * share).round(2),
          per_person_amount: (@estate_amount * per_person).round(2),
          label_ar: HEIR_LABELS[type][:ar],
          label_en: HEIR_LABELS[type][:en],
          reason_ar: SHARE_REASONS[@reasons[type]] || ""
        )
      end

      blocked_info = @blocked.map do |type, reason|
        { heir_type: type, label_ar: HEIR_LABELS[type][:ar], label_en: HEIR_LABELS[type][:en], reason: reason }
      end

      debug = {
        input_heirs: @input_heirs,
        active_heirs: @active_heirs,
        blocked_keys: @blocked.keys,
        fixed_keys: @fixed.keys,
        residuary_types: @residuary.map { |r| r[:type] },
        total_fixed: total_fixed.to_f.round(4)
      }

      Result.new(
        heir_shares: heir_results,
        base_denominator: base,
        adjusted_denominator: adjusted,
        awl_applied: awl,
        radd_applied: radd,
        estate_amount: @estate_amount,
        blocked_heirs: blocked_info,
        debug_info: debug
      )
    end

    # Calculates the base denominator (أصل المسألة) as the LCM of all fixed share denominators.
    # حساب أصل المسألة كأصغر مضاعف مشترك لمقامات الأنصبة
    def calculate_base_denominator
      return 1 if @fixed.empty?
      @fixed.values.map(&:denominator).reduce(1, :lcm)
    end

    # Calculates the adjusted denominator after Awl (عول) — when total shares exceed the base.
    # حساب أصل المسألة بعد العول
    def calculate_awl_adjusted_denominator(base)
      total_numerators = @fixed.values.sum { |s| s.numerator * (base / s.denominator) }
      [base, total_numerators].max
    end

    # Reduces all shares proportionally when Awl applies (total > 1).
    # تخفيض جميع الأنصبة بالتناسب عند تطبيق العول
    def reduce_shares_proportionally!(shares, total)
      shares.transform_values! { |s| s / total }
    end

    # Redistributes surplus estate to non-spouse fixed heirs (Radd / رد).
    # Spouses never receive Radd — surplus goes proportionally to other fixed-share heirs.
    # إعادة توزيع الفائض على أصحاب الفروض من غير الزوجين (الرد)
    def redistribute_surplus_to_non_spouse!(shares)
      spouse_types = %i[husband wife]
      total = shares.values.sum(Rational(0))
      remainder = Rational(1) - total

      return if remainder <= 0

      non_spouse = shares.reject { |k, _| spouse_types.include?(k) }
      total_non_spouse = non_spouse.values.sum(Rational(0))

      return if total_non_spouse == 0

      non_spouse.each do |type, share|
        shares[type] = share + remainder * (share / total_non_spouse)
      end
    end
  end
end
