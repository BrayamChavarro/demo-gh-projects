const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const MIN_PASSWORD_LENGTH = 8;

/**
 * Validates the sign-in form values.
 *
 * @param {{ email?: string, password?: string }} credentials
 * @returns {{ ok: true } | { ok: false, message: string }}
 */
export function validateCredentials(credentials) {
  const email = (credentials.email ?? "").trim();
  const password = credentials.password ?? "";

  if (email === "") {
    return { ok: false, message: "Email is required." };
  }

  if (!EMAIL_PATTERN.test(email)) {
    return { ok: false, message: "Enter a valid email address." };
  }

  if (password === "") {
    return { ok: false, message: "Password is required." };
  }

  if (password.length < MIN_PASSWORD_LENGTH) {
    return { ok: false, message: `Password must be at least ${MIN_PASSWORD_LENGTH} characters.` };
  }

  return { ok: true };
}
