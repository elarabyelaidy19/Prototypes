# Inheritance::Constants — ثوابت المواريث
# Static data for heir labels (Arabic/English) and share reason descriptions.
# Used by ResultBuilder to populate HeirShare structs with display text.
module Inheritance
  module Constants
    # HEIR_LABELS — أسماء الورثة
    # Maps each heir type to its Arabic and English display name.
    HEIR_LABELS = {
      husband:          { ar: "الزوج",          en: "Husband" },
      wife:             { ar: "الزوجة",         en: "Wife" },
      father:           { ar: "الأب",           en: "Father" },
      mother:           { ar: "الأم",           en: "Mother" },
      grandfather:      { ar: "الجد",           en: "Grandfather" },
      grandmother:      { ar: "الجدة",          en: "Grandmother" },
      son:              { ar: "الابن",          en: "Son" },
      daughter:         { ar: "البنت",          en: "Daughter" },
      sons_son:         { ar: "ابن الابن",      en: "Grandson (son's son)" },
      sons_daughter:    { ar: "بنت الابن",      en: "Granddaughter (son's daughter)" },
      full_brother:     { ar: "الأخ الشقيق",    en: "Full Brother" },
      full_sister:      { ar: "الأخت الشقيقة",  en: "Full Sister" },
      paternal_brother: { ar: "الأخ لأب",       en: "Half-Brother (paternal)" },
      paternal_sister:  { ar: "الأخت لأب",      en: "Half-Sister (paternal)" },
      maternal_brother: { ar: "الأخ لأم",       en: "Half-Brother (maternal)" },
      maternal_sister:  { ar: "الأخت لأم",      en: "Half-Sister (maternal)" }
    }.freeze

    # SHARE_REASONS — أسباب الأنصبة
    # Maps each reason code to its Arabic jurisprudence explanation.
    # Each reason describes WHY a heir receives a specific share.
    SHARE_REASONS = {
      # Spouse reasons — أسباب نصيب الزوج/الزوجة
      husband_with_descendants:    "الربع فرضاً لوجود الفرع الوارث — 1/4 fixed share due to presence of descendants",
      husband_without_descendants: "النصف فرضاً لعدم وجود الفرع الوارث — 1/2 fixed share due to absence of descendants",
      wife_with_descendants:       "الثمن فرضاً لوجود الفرع الوارث — 1/8 fixed share due to presence of descendants",
      wife_without_descendants:    "الربع فرضاً لعدم وجود الفرع الوارث — 1/4 fixed share due to absence of descendants",

      # Father reasons — أسباب نصيب الأب
      father_sixth_with_male:      "السدس فرضاً لوجود الفرع الوارث الذكر — 1/6 fixed share due to male descendants",
      father_sixth_plus_residuary: "السدس فرضاً + الباقي تعصيباً لوجود الفرع الوارث المؤنث فقط — 1/6 fixed + residuary (female descendants only)",
      father_residuary:            "الباقي تعصيباً بالنفس — Residuary by himself",

      # Mother reasons — أسباب نصيب الأم
      mother_sixth:                "السدس فرضاً لوجود الفرع الوارث أو الجمع من الإخوة — 1/6 fixed (descendants or 2+ siblings exist)",
      mother_third:                "الثلث فرضاً لعدم وجود الفرع الوارث وعدم الجمع من الإخوة — 1/3 fixed (no descendants, fewer than 2 siblings)",
      mother_third_remainder:      "ثلث الباقي بعد نصيب الزوج/الزوجة (المسألة العمرية) — 1/3 of remainder after spouse (Umariyyatan case)",

      # Daughter reasons — أسباب نصيب البنت
      daughter_half:               "النصف فرضاً للانفراد وعدم المعصب — 1/2 fixed (sole daughter, no male co-heir)",
      daughter_two_thirds:         "الثلثان فرضاً للتعدد وعدم المعصب — 2/3 fixed (multiple daughters, no male co-heir)",
      daughter_residuary_with_son: "الباقي تعصيباً بالغير (للذكر مثل حظ الأنثيين) — Residuary with sons (male gets 2x female)",

      # Granddaughter reasons — أسباب نصيب بنت الابن
      sons_daughter_half:          "النصف فرضاً للانفراد وعدم المعصب — 1/2 fixed (sole granddaughter, no male co-heir)",
      sons_daughter_two_thirds:    "الثلثان فرضاً للتعدد وعدم المعصب — 2/3 fixed (multiple granddaughters, no male co-heir)",
      sons_daughter_sixth:         "السدس فرضاً تكملة الثلثين — 1/6 fixed to complete 2/3 (with one daughter)",
      sons_daughter_residuary:     "الباقي تعصيباً بالغير (للذكر مثل حظ الأنثيين) — Residuary with grandsons (male gets 2x female)",

      # Grandfather reasons — أسباب نصيب الجد
      grandfather_sixth:           "السدس فرضاً لوجود الفرع الوارث الذكر — 1/6 fixed (male descendants exist)",
      grandfather_sixth_residuary: "السدس فرضاً + الباقي تعصيباً — 1/6 fixed + residuary",
      grandfather_residuary:       "الباقي تعصيباً بالنفس — Residuary by himself",

      # Grandmother reason — سبب نصيب الجدة
      grandmother_sixth:           "السدس فرضاً — 1/6 fixed share",

      # Son / Grandson reasons — أسباب نصيب الابن / ابن الابن
      son_residuary:               "الباقي تعصيباً بالنفس — Residuary by himself",
      sons_son_residuary:          "الباقي تعصيباً بالنفس — Residuary by himself",

      # Full sibling reasons — أسباب نصيب الإخوة الأشقاء
      full_brother_residuary:      "الباقي تعصيباً بالنفس — Residuary by himself",
      full_sister_half:            "النصف فرضاً للانفراد وعدم المعصب — 1/2 fixed (sole sister, no male co-heir)",
      full_sister_two_thirds:      "الثلثان فرضاً للتعدد وعدم المعصب — 2/3 fixed (multiple sisters, no male co-heir)",
      full_sister_residuary_with:  "الباقي تعصيباً بالغير (للذكر مثل حظ الأنثيين) — Residuary with brothers (male gets 2x female)",
      full_sister_asaba_with_daughters: "الباقي تعصيباً مع الغير — Residuary with daughters",

      # Paternal sibling reasons — أسباب نصيب الإخوة لأب
      paternal_brother_residuary:  "الباقي تعصيباً بالنفس — Residuary by himself",
      paternal_sister_half:        "النصف فرضاً للانفراد وعدم المعصب — 1/2 fixed (sole sister, no male co-heir)",
      paternal_sister_two_thirds:  "الثلثان فرضاً للتعدد وعدم المعصب — 2/3 fixed (multiple sisters, no male co-heir)",
      paternal_sister_sixth:       "السدس فرضاً تكملة الثلثين — 1/6 fixed to complete 2/3 (with one full sister)",
      paternal_sister_residuary:   "الباقي تعصيباً بالغير (للذكر مثل حظ الأنثيين) — Residuary with brothers (male gets 2x female)",
      paternal_sister_asaba_with_daughters: "الباقي تعصيباً مع الغير — Residuary with daughters",

      # Maternal sibling reasons — أسباب نصيب الإخوة لأم
      maternal_sibling_sixth:      "السدس فرضاً للانفراد — 1/6 fixed (single maternal sibling)",
      maternal_sibling_third:      "الثلث فرضاً للتعدد (يقسم بالتساوي) — 1/3 fixed shared equally (multiple maternal siblings)"
    }.freeze
  end
end
