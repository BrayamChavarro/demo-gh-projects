const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const MIN_PASSWORD_LENGTH = 8;

const MESSAGES = {
  en: {
    emailRequired: "Email is required.",
    emailInvalid: "Enter a valid email address.",
    passwordRequired: "Password is required.",
    passwordTooShort: (min) => `Password must be at least ${min} characters.`,
  },
  es: {
    emailRequired: "El correo es obligatorio.",
    emailInvalid: "Ingrese un correo válido.",
    passwordRequired: "La contraseña es obligatoria.",
    passwordTooShort: (min) => `La contraseña debe tener al menos ${min} caracteres.`,
  },
};

/**
 * Validates the sign-in form values.
 *
 * @param {{ email?: string, password?: string }} credentials
 * @param {"en" | "es"} [locale] Language for the validation messages.
 * @returns {{ ok: true } | { ok: false, message: string }}
 */
export function validateCredentials(credentials, locale = "en") {
  const t = MESSAGES[locale] ?? MESSAGES.en;
  const email = (credentials.email ?? "").trim();
  const password = credentials.password ?? "";

  if (email === "") {
    return { ok: false, message: t.emailRequired };
  }

  if (!EMAIL_PATTERN.test(email)) {
    return { ok: false, message: t.emailInvalid };
  }

  if (password === "") {
    return { ok: false, message: t.passwordRequired };
  }

  if (password.length < MIN_PASSWORD_LENGTH) {
    return { ok: false, message: t.passwordTooShort(MIN_PASSWORD_LENGTH) };
  }

  return { ok: true };
}
