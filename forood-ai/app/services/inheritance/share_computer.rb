# Inheritance::ShareComputer — حساب الأنصبة
# Computes the fixed shares (فرض / Fard) and residuary shares (تعصيب / Tasib)
# for each heir type based on Islamic inheritance rules.
# Produces three data structures: @fixed, @reasons, and @residuary.
module Inheritance
  class ShareComputer
    include HeirHelpers

    attr_reader :fixed, :reasons, :residuary

    def initialize(blocker:, input_heirs:)
      @blocker = blocker
      @input_heirs = input_heirs
      @fixed = {}
      @reasons = {}
      @residuary = []
    end

    # Computes shares for all heir categories in the correct precedence order.
    # حساب أنصبة جميع فئات الورثة بالترتيب الصحيح
    def compute_all_shares(heirs)
      compute_spouse_share(heirs)
      compute_children_shares(heirs)
      compute_grandchildren_shares(heirs)
      compute_father_share(heirs)
      compute_mother_share(heirs)
      compute_grandfather_share(heirs)
      compute_grandmother_share(heirs)
      compute_maternal_siblings_shares(heirs)
      compute_full_siblings_shares(heirs)
      compute_paternal_siblings_shares(heirs)
      apply_umariyyatan_special_case!(heirs)
    end

    private

    # Spouse share — نصيب الزوج / الزوجة
    # Husband: 1/2 without descendants, 1/4 with descendants.
    # Wife: 1/4 without descendants, 1/8 with descendants.
    def compute_spouse_share(heirs)
      if heir_count(heirs, :husband) > 0
        if descendants_present?(heirs)
          @fixed[:husband] = Rational(1, 4)
          @reasons[:husband] = :husband_with_descendants
        else
          @fixed[:husband] = Rational(1, 2)
          @reasons[:husband] = :husband_without_descendants
        end
      end

      if heir_count(heirs, :wife) > 0
        if descendants_present?(heirs)
          @fixed[:wife] = Rational(1, 8)
          @reasons[:wife] = :wife_with_descendants
        else
          @fixed[:wife] = Rational(1, 4)
          @reasons[:wife] = :wife_without_descendants
        end
      end
    end

    # Children shares — أنصبة الأولاد (الابن والبنت)
    # Sons are always residuary (عصبة بالنفس). Daughters with sons become residuary too
    # (عصبة بالغير, male gets 2x female). Daughters alone get fixed shares.
    def compute_children_shares(heirs)
      sons = heir_count(heirs, :son)
      daughters = heir_count(heirs, :daughter)

      if sons > 0
        @residuary << { type: :son, count: sons, weight: 2 }
        @reasons[:son] = :son_residuary
        if daughters > 0
          @residuary << { type: :daughter, count: daughters, weight: 1 }
          @reasons[:daughter] = :daughter_residuary_with_son
        end
      elsif daughters > 0
        if daughters == 1
          @fixed[:daughter] = Rational(1, 2)
          @reasons[:daughter] = :daughter_half
        else
          @fixed[:daughter] = Rational(2, 3)
          @reasons[:daughter] = :daughter_two_thirds
        end
      end
    end

    # Grandchildren shares — أنصبة أولاد الابن (ابن الابن وبنت الابن)
    # Similar rules to children. Granddaughters may get 1/6 to complete 2/3
    # when one daughter already takes 1/2 (تكملة الثلثين).
    def compute_grandchildren_shares(heirs)
      grandsons = heir_count(heirs, :sons_son)
      granddaughters = heir_count(heirs, :sons_daughter)
      daughters = heir_count(heirs, :daughter)

      return if grandsons == 0 && granddaughters == 0

      if grandsons > 0
        @residuary << { type: :sons_son, count: grandsons, weight: 2 }
        @reasons[:sons_son] = :sons_son_residuary
        if granddaughters > 0
          @residuary << { type: :sons_daughter, count: granddaughters, weight: 1 }
          @reasons[:sons_daughter] = :sons_daughter_residuary
        end
      elsif granddaughters > 0
        if daughters == 0
          if granddaughters == 1
            @fixed[:sons_daughter] = Rational(1, 2)
            @reasons[:sons_daughter] = :sons_daughter_half
          else
            @fixed[:sons_daughter] = Rational(2, 3)
            @reasons[:sons_daughter] = :sons_daughter_two_thirds
          end
        elsif daughters == 1
          # One daughter took 1/2, granddaughter(s) get 1/6 to complete 2/3
          # البنت أخذت النصف، وبنت الابن تأخذ السدس تكملة الثلثين
          @fixed[:sons_daughter] = Rational(1, 6)
          @reasons[:sons_daughter] = :sons_daughter_sixth
        end
      end
    end

    # Father's share — نصيب الأب
    # With male descendants: 1/6 fixed only (السدس فرضاً).
    # With female descendants only: 1/6 fixed + residuary (السدس + الباقي تعصيباً).
    # No descendants: pure residuary (الباقي تعصيباً بالنفس).
    def compute_father_share(heirs)
      return unless heir_count(heirs, :father) > 0

      if male_descendants_present?(heirs)
        @fixed[:father] = Rational(1, 6)
        @reasons[:father] = :father_sixth_with_male
      elsif descendants_present?(heirs)
        @fixed[:father] = Rational(1, 6)
        @residuary << { type: :father, count: 1, weight: 1 }
        @reasons[:father] = :father_sixth_plus_residuary
      else
        @residuary << { type: :father, count: 1, weight: 1 }
        @reasons[:father] = :father_residuary
      end
    end

    # Mother's share — نصيب الأم
    # With descendants or 2+ siblings: 1/6 (السدس).
    # Otherwise: 1/3 (الثلث).
    def compute_mother_share(heirs)
      return unless heir_count(heirs, :mother) > 0

      if descendants_present?(heirs) || total_sibling_count_before_blocking >= 2
        @fixed[:mother] = Rational(1, 6)
        @reasons[:mother] = :mother_sixth
      else
        @fixed[:mother] = Rational(1, 3)
        @reasons[:mother] = :mother_third
      end
    end

    # Grandfather's share — نصيب الجد
    # Same logic as father: acts as substitute when father is absent.
    # نفس منطق الأب: يحل محله عند غيابه
    def compute_grandfather_share(heirs)
      return unless heir_count(heirs, :grandfather) > 0

      if male_descendants_present?(heirs)
        @fixed[:grandfather] = Rational(1, 6)
        @reasons[:grandfather] = :grandfather_sixth
      elsif descendants_present?(heirs)
        @fixed[:grandfather] = Rational(1, 6)
        @residuary << { type: :grandfather, count: 1, weight: 1 }
        @reasons[:grandfather] = :grandfather_sixth_residuary
      else
        @residuary << { type: :grandfather, count: 1, weight: 1 }
        @reasons[:grandfather] = :grandfather_residuary
      end
    end

    # Grandmother's share — نصيب الجدة
    # Always 1/6 when not blocked by mother (السدس فرضاً).
    def compute_grandmother_share(heirs)
      return unless heir_count(heirs, :grandmother) > 0

      @fixed[:grandmother] = Rational(1, 6)
      @reasons[:grandmother] = :grandmother_sixth
    end

    # Maternal siblings' shares — أنصبة الإخوة لأم
    # One maternal sibling: 1/6 (السدس). Two or more: 1/3 shared equally (الثلث بالتساوي).
    # Males and females share equally — unique among all heir categories.
    def compute_maternal_siblings_shares(heirs)
      brothers = heir_count(heirs, :maternal_brother)
      sisters = heir_count(heirs, :maternal_sister)
      total = brothers + sisters
      return if total == 0

      share = total == 1 ? Rational(1, 6) : Rational(1, 3)
      reason = total == 1 ? :maternal_sibling_sixth : :maternal_sibling_third

      if brothers > 0
        @fixed[:maternal_brother] = share * Rational(brothers, total)
        @reasons[:maternal_brother] = reason
      end
      if sisters > 0
        @fixed[:maternal_sister] = share * Rational(sisters, total)
        @reasons[:maternal_sister] = reason
      end
    end

    # Full siblings' shares — أنصبة الإخوة الأشقاء
    # Brothers: residuary (عصبة بالنفس). Sisters with brothers: residuary with them (عصبة بالغير).
    # Sisters alone with female descendants: residuary with daughters (عصبة مع الغير).
    # Sisters alone without descendants: fixed shares (فرض).
    def compute_full_siblings_shares(heirs)
      brothers = heir_count(heirs, :full_brother)
      sisters = heir_count(heirs, :full_sister)

      return if brothers == 0 && sisters == 0

      if brothers > 0
        @residuary << { type: :full_brother, count: brothers, weight: 2 }
        @reasons[:full_brother] = :full_brother_residuary
        if sisters > 0
          @residuary << { type: :full_sister, count: sisters, weight: 1 }
          @reasons[:full_sister] = :full_sister_residuary_with
        end
      elsif sisters > 0
        if only_female_descendants?(heirs)
          # Sisters become residuary with daughters — الأخوات عصبة مع البنات
          @residuary << { type: :full_sister, count: sisters, weight: 1 }
          @reasons[:full_sister] = :full_sister_asaba_with_daughters
          @blocker.exclude_paternal_siblings_by_full_sister_residuary!(heirs)
        else
          @fixed[:full_sister] = sisters == 1 ? Rational(1, 2) : Rational(2, 3)
          @reasons[:full_sister] = sisters == 1 ? :full_sister_half : :full_sister_two_thirds
        end
      end
    end

    # Paternal siblings' shares — أنصبة الإخوة لأب
    # Similar to full siblings but lower priority. May get 1/6 to complete 2/3
    # when one full sister already takes 1/2 (تكملة الثلثين).
    def compute_paternal_siblings_shares(heirs)
      brothers = heir_count(heirs, :paternal_brother)
      sisters = heir_count(heirs, :paternal_sister)

      brothers = 0 if @blocker.blocked.key?(:paternal_brother)
      sisters = 0 if @blocker.blocked.key?(:paternal_sister)

      return if brothers == 0 && sisters == 0

      if brothers > 0
        @residuary << { type: :paternal_brother, count: brothers, weight: 2 }
        @reasons[:paternal_brother] = :paternal_brother_residuary
        if sisters > 0
          @residuary << { type: :paternal_sister, count: sisters, weight: 1 }
          @reasons[:paternal_sister] = :paternal_sister_residuary
        end
      elsif sisters > 0
        if only_female_descendants?(heirs)
          @residuary << { type: :paternal_sister, count: sisters, weight: 1 }
          @reasons[:paternal_sister] = :paternal_sister_asaba_with_daughters
        elsif heir_count(heirs, :full_sister) == 1 && @fixed.key?(:full_sister)
          # One full sister took 1/2, paternal sister gets 1/6 to complete 2/3
          # الأخت الشقيقة أخذت النصف، والأخت لأب تأخذ السدس تكملة الثلثين
          @fixed[:paternal_sister] = Rational(1, 6)
          @reasons[:paternal_sister] = :paternal_sister_sixth
        elsif heir_count(heirs, :full_sister) == 0
          @fixed[:paternal_sister] = sisters == 1 ? Rational(1, 2) : Rational(2, 3)
          @reasons[:paternal_sister] = sisters == 1 ? :paternal_sister_half : :paternal_sister_two_thirds
        end
      end
    end

    # Umariyyatan Special Case — المسألة العمرية (العمريتان)
    # When only a spouse + both parents exist (no other heirs):
    # Mother gets 1/3 of the REMAINDER (not 1/3 of the whole estate).
    # Father takes whatever is left as residuary.
    # Named after the ruling of Umar ibn al-Khattab (رضي الله عنه).
    def apply_umariyyatan_special_case!(heirs)
      active_types = heirs.keys
      has_spouse = active_types.include?(:husband) || active_types.include?(:wife)
      has_both_parents = active_types.include?(:father) && active_types.include?(:mother)
      others = active_types - %i[husband wife father mother]

      return unless has_spouse && has_both_parents && others.empty?

      spouse_type = active_types.include?(:husband) ? :husband : :wife
      spouse_share = @fixed[spouse_type]
      remainder = Rational(1) - spouse_share

      # Mother gets 1/3 of remainder — الأم تأخذ ثلث الباقي
      @fixed[:mother] = remainder * Rational(1, 3)
      @reasons[:mother] = :mother_third_remainder

      # Father takes the rest as residuary — الأب يأخذ الباقي تعصيباً
      unless @residuary.any? { |r| r[:type] == :father }
        @residuary << { type: :father, count: 1, weight: 1 }
        @reasons[:father] = :father_residuary
      end
      @fixed.delete(:father)
    end

    # Counts all siblings from the original input (before blocking).
    # Used to determine if mother gets 1/6 (when 2+ siblings exist).
    # عدد الإخوة الأصلي قبل الحجب — يُستخدم لتحديد نصيب الأم
    def total_sibling_count_before_blocking
      %i[full_brother full_sister paternal_brother paternal_sister
         maternal_brother maternal_sister].sum { |k| @input_heirs.fetch(k, 0) }
    end
  end
end
