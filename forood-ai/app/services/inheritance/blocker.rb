# Inheritance::Blocker — حجب الحرمان
# Implements Islamic inheritance blocking rules (Hajb al-Hirman / حجب الحرمان).
# Certain heirs completely exclude others from inheriting.
# For example: the presence of a son blocks grandsons and granddaughters.
module Inheritance
  class Blocker
    include HeirHelpers

    attr_reader :blocked

    def initialize(input_heirs:)
      @input_heirs = input_heirs
      @blocked = {}
    end

    # Applies all static blocking rules and returns only the active (non-blocked) heirs.
    # تطبيق قواعد الحجب الثابتة وإرجاع الورثة الفاعلين فقط (غير المحجوبين)
    def apply_exclusion_rules(heirs)
      # Son blocks grandson and granddaughter
      # الابن يحجب ابن الابن وبنت الابن
      if heir_count(heirs, :son) > 0
        exclude_heir!(heirs, :sons_son, "محجوب بالابن — Blocked by son")
        exclude_heir!(heirs, :sons_daughter, "محجوبة بالابن — Blocked by son")
      end

      # Father blocks grandfather and all siblings
      # الأب يحجب الجد وجميع الإخوة والأخوات
      if heir_count(heirs, :father) > 0
        exclude_heir!(heirs, :grandfather, "محجوب بالأب — Blocked by father")
        %i[full_brother full_sister paternal_brother paternal_sister
           maternal_brother maternal_sister].each do |sibling|
          exclude_heir!(heirs, sibling, "محجوب بالأب — Blocked by father")
        end
      end

      # Son or grandson blocks all full and paternal siblings
      # الابن أو ابن الابن يحجب الإخوة الأشقاء والإخوة لأب
      if heir_count(heirs, :son) > 0 || heir_count(heirs, :sons_son) > 0
        %i[full_brother full_sister paternal_brother paternal_sister].each do |sibling|
          exclude_heir!(heirs, sibling, "محجوب بالفرع الوارث الذكر — Blocked by male descendant")
        end
      end

      # Any descendant, father, or grandfather blocks maternal siblings
      # الفرع الوارث أو الأصل الذكر يحجب الإخوة لأم
      if descendants_present?(heirs) || heir_count(heirs, :father) > 0 || heir_count(heirs, :grandfather) > 0
        %i[maternal_brother maternal_sister].each do |sibling|
          exclude_heir!(heirs, sibling, "محجوب بالفرع الوارث أو الأصل الذكر — Blocked by descendant or male ascendant")
        end
      end

      # Full brother blocks paternal brother and paternal sister
      # الأخ الشقيق يحجب الأخ لأب والأخت لأب
      if heir_count(heirs, :full_brother) > 0 && !@blocked.key?(:full_brother)
        exclude_heir!(heirs, :paternal_brother, "محجوب بالأخ الشقيق — Blocked by full brother")
        exclude_heir!(heirs, :paternal_sister, "محجوبة بالأخ الشقيق — Blocked by full brother")
      end

      # Two or more full sisters (with fixed share) block paternal sister
      # unless a paternal brother exists to make her residuary
      # الأختان الشقيقتان فأكثر يحجبن الأخت لأب ما لم يوجد أخ لأب يعصّبها
      if heir_count(heirs, :full_sister) >= 2 && !@blocked.key?(:full_sister) &&
         heir_count(heirs, :paternal_brother) == 0 && !only_female_descendants?(heirs)
        exclude_heir!(heirs, :paternal_sister, "محجوبة بالأختين الشقيقتين فأكثر — Blocked by 2+ full sisters")
      end

      # Two or more daughters block granddaughter unless grandson is present
      # البنتان فأكثر يحجبن بنت الابن ما لم يوجد ابن الابن
      if heir_count(heirs, :daughter) >= 2 && heir_count(heirs, :sons_son) == 0
        exclude_heir!(heirs, :sons_daughter, "محجوبة ببنتين فأكثر لعدم وجود ابن الابن — Blocked by 2+ daughters (no grandson)")
      end

      # Mother blocks all grandmothers
      # الأم تحجب الجدة
      if heir_count(heirs, :mother) > 0
        exclude_heir!(heirs, :grandmother, "محجوبة بالأم — Blocked by mother")
      end

      heirs.reject { |k, _| @blocked.key?(k) }
    end

    # Dynamic blocking: when full sisters become residuary with daughters (عصبة مع الغير),
    # they block paternal siblings mid-computation.
    # حجب ديناميكي: الأخت الشقيقة عصبة مع الغير تحجب الإخوة لأب
    def exclude_paternal_siblings_by_full_sister_residuary!(heirs)
      if heir_count(heirs, :paternal_brother) > 0 && !@blocked.key?(:paternal_brother)
        @blocked[:paternal_brother] = "محجوب بالأخت الشقيقة عصبة مع الغير — Blocked by full sister (residuary with daughters)"
      end
      if heir_count(heirs, :paternal_sister) > 0 && !@blocked.key?(:paternal_sister)
        @blocked[:paternal_sister] = "محجوبة بالأخت الشقيقة عصبة مع الغير — Blocked by full sister (residuary with daughters)"
      end
    end

    # Safety net: removes any blocked heir's data from the computed shares.
    # شبكة أمان: حذف بيانات أي وارث محجوب من الأنصبة المحسوبة
    def purge_excluded_heirs_from_shares!(fixed:, reasons:, residuary:)
      @blocked.each_key do |type|
        fixed.delete(type)
        reasons.delete(type)
        residuary.reject! { |r| r[:type] == type }
      end
    end

    private

    # Records a heir as blocked if they are present and not already blocked.
    # تسجيل وارث كمحجوب إذا كان موجوداً ولم يُحجب مسبقاً
    def exclude_heir!(heirs, heir_type, reason)
      return unless heir_count(heirs, heir_type) > 0
      return if @blocked.key?(heir_type)
      @blocked[heir_type] = reason
    end
  end
end
