# Inheritance::Validator — التحقق من صحة المدخلات
# Validates input coherence before calculation begins.
# Ensures the deceased's gender is consistent with the heir list.
module Inheritance
  class Validator
    def initialize(deceased_gender:, heirs:)
      @deceased_gender = deceased_gender
      @heirs = heirs
    end

    # Raises ArgumentError if the input is logically impossible.
    # يرفع خطأ إذا كانت المدخلات غير منطقية (مثلاً: ذكر له زوج)
    def validate!
      if @deceased_gender == :male && @heirs.key?(:husband)
        raise ArgumentError, "المتوفى ذكر لا يمكن أن يكون له زوج — A male deceased cannot have a husband"
      end
      if @deceased_gender == :female && @heirs.key?(:wife)
        raise ArgumentError, "المتوفاة أنثى لا يمكن أن يكون لها زوجة — A female deceased cannot have a wife"
      end
    end
  end
end
