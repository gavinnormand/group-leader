//
//  AuthView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 6/29/26.
//

import SwiftUI
import Supabase

enum AuthStep {
    case signIn, signUp, verify
}

private let pendingVerificationEmailKey = "pendingVerificationEmail"

struct AuthView: View {
    @State private var email = UserDefaults.standard.string(forKey: pendingVerificationEmailKey) ?? ""
    @State private var password = ""
    @State private var otp = ""
    @State private var step: AuthStep = UserDefaults.standard.string(forKey: pendingVerificationEmailKey) == nil ? .signIn : .verify
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            switch step {
            case .signIn:
                Text("Welcome back!")
                    .font(.title2.bold())

                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .textInputStyle()
                        
                    SecureField("Password", text: $password)
                        .textInputStyle()

                Button("Sign In") {
                    Task { await signIn() }
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle)
                .disabled(isLoading || email.isEmpty || password.isEmpty)

                Button("Need an account? Sign up") {
                    step = .signUp
                    errorMessage = nil
                }
                .font(.footnote)

            case .signUp:
                Text("Create account")
                    .font(.title2.bold())

                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .textInputStyle()

                SecureField("Password", text: $password)
                    .textInputStyle()

                Button("Sign Up") {
                    Task { await signUp() }
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle)
                .disabled(isLoading || email.isEmpty || password.isEmpty)

                Button("Already have an account? Sign in") {
                    step = .signIn
                    errorMessage = nil
                }
                .font(.footnote)

            case .verify:
                Text("Check your email")
                    .font(.title2.bold())

                Text("We sent a 6-digit code to \(email)")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)

                TextField("6-digit code", text: $otp)
                    .keyboardType(.numberPad)
                    .textInputStyle()
                    .onChange(of: otp) { oldValue, newValue in
                        if newValue.count > 6 {
                            otp = String(newValue.prefix(6))
                        }
                    }

                Button("Verify") {
                    Task { await verifyOTP() }
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle)
                .disabled(isLoading || otp.isEmpty)

                Button("Resend code") {
                    Task { await resendCode() }
                }
                .font(.footnote)
                .disabled(isLoading)

                Button("Use a different email") {
                    clearPendingVerification()
                    otp = ""
                    step = .signIn
                    errorMessage = nil
                }
                .font(.footnote)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .animation(.default, value: step)
    }

    private func signIn() async {
        isLoading = true
        errorMessage = nil
        do {
            try await supabase.auth.signIn(email: email, password: password)
            clearPendingVerification()
        } catch {
            if error.localizedDescription.localizedCaseInsensitiveContains("not confirmed") {
                await resendCode()
                savePendingVerification()
                step = .verify
            } else {
                errorMessage = "Sign in error: \(error.localizedDescription)"
            }
        }
        isLoading = false
    }

    private func signUp() async {
        isLoading = true
        errorMessage = nil
        do {
            try await supabase.auth.signUp(email: email, password: password)
            savePendingVerification()
            step = .verify
        } catch {
            errorMessage = "Sign up error: \(error.localizedDescription)"
        }
        isLoading = false
    }

    private func verifyOTP() async {
        isLoading = true
        errorMessage = nil
        do {
            try await supabase.auth.verifyOTP(
                email: email,
                token: otp,
                type: .signup
            )
            clearPendingVerification()
        } catch {
            errorMessage = "Verify code error: \(error.localizedDescription)"
        }
        isLoading = false
    }

    private func resendCode() async {
        do {
            try await supabase.auth.resend(email: email, type: .signup)
        } catch {
            errorMessage = "Resend code error: \(error.localizedDescription)"
        }
    }

    private func savePendingVerification() {
        UserDefaults.standard.set(email, forKey: pendingVerificationEmailKey)
    }

    private func clearPendingVerification() {
        UserDefaults.standard.removeObject(forKey: pendingVerificationEmailKey)
    }
}

#Preview {
    AuthView()
}
