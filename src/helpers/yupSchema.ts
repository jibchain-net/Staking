import * as Yup from "yup";

export const yupSchema = (balance: string) => {
  const schema = Yup.object().shape({
    amount: Yup.string()
      .test("Digits only", "The field should have digits only", (value) => {
        if (value) {
          return /\d/.test(value);
        }
      })
      .test(
        "Min value",
        `Min value 0.000000000000000001 ATOKEN`,
        (value) => Number(value) >= 0.000000000000000001
      )
      .test(
        "Max value",
        `Max value ${balance} ATOKEN`,
        (value) => Number(value) <= Number(balance)
      )
      .required("Please complete this field"),
  });
  return { schema };
};
