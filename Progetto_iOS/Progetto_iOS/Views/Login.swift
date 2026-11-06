import SwiftUI

struct PasswordValidator {
    static func isValid(_ pass: String) -> Bool {
        let uppercasePattern = ".*[A-Z].*"
        let numberPattern = ".*[0-9].*"
        let specialPattern = ".*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?].*"
        
        let hasUpper = NSPredicate(format: "SELF MATCHES %@", uppercasePattern).evaluate(with: pass)
        let hasNumber = NSPredicate(format: "SELF MATCHES %@", numberPattern).evaluate(with: pass)
        let hasSpecial = NSPredicate(format: "SELF MATCHES %@", specialPattern).evaluate(with: pass)
        
        return hasUpper && hasNumber && hasSpecial && pass.count >= 8
    }
}

struct Login: View {
    @Binding var profile: UserProfile
    @Binding var isRegistered: Bool
    
    @State private var currentStep = 1
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            switch currentStep {
            case 1:
                Text("Buongiorno,\ncome ti chiami?")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                
                TextField("Inserisci il tuo nome", text: $profile.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Avanti") {
                    if !profile.name.trimmingCharacters(in: .whitespaces).isEmpty {
                        currentStep = 2
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(profile.name.trimmingCharacters(in: .whitespaces).isEmpty)
                
            case 2:
                let suffix = profile.isMale ? "o" : "a"
                Text("\(profile.name), pronto/\(suffix) per iniziare il tuo percorso al meglio?")
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding()
                
                Picker("Genere", selection: $profile.isMale) {
                    Text("Uomo").tag(true)
                    Text("Donna").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Button("Inizia quiz") {
                    currentStep = 3
                }
                .buttonStyle(.borderedProminent)
                
            case 3:
                Form {
                    Section(header: Text("Dati Fisici")) {
                        Stepper("Età: \(profile.age)", value: $profile.age, in: 14...90)
                        
                        HStack {
                            Text("Peso (kg):")
                            TextField("Peso", value: $profile.weight, format: .number)
                        }
                        
                        HStack {
                            Text("Altezza (cm):")
                            TextField("Altezza", value: $profile.height, format: .number)
                        }
                    }
                    
                    Section(header: Text("Obiettivo")) {
                        Picker("Cosa vuoi ottenere?", selection: $profile.goal) {
                            Text("Dimagrire").tag("Dimagrire")
                            Text("Mantenere").tag("Mantenere")
                            Text("Prendere peso").tag("Prendere peso")
                        }
                    }
                }
                
                Button("Completa Quiz") {
                    currentStep = 4
                }
                .buttonStyle(.borderedProminent)
                
            case 4:
                Text("Perfetto \(profile.name), ora siamo pronti per creare il tuo piano nutrizionale completamente gratuito!")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button("Crea il tuo account GRATUITO!") {
                    currentStep = 5
                }
                .buttonStyle(.borderedProminent)
                
            case 5:
                Form {
                    Section(header: Text("Crea Account")) {
                        TextField("Email", text: $profile.email)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Password", text: $profile.password)
                    }
                    
                    Section(footer: Text("La password deve contenere almeno 8 caratteri, una lettera maiuscola, un numero e un carattere speciale.")) {
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        Button("Registrati") {
                            if PasswordValidator.isValid(profile.password) && !profile.email.isEmpty {
                                isRegistered = true
                            } else {
                                errorMessage = "Password non valida! Controlla i requisiti."
                            }
                        }
                    }
                }
                
            default:
                EmptyView()
            }
        }
        .padding()
    }
}
