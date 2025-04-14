import SwiftUI
import PhotosUI

struct FormView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var localization = LocalizationManager.shared
    @ObservedObject var viewModel: ContentViewModel
    @State private var prenom: String = ""
    @State private var age: String = ""
    @State private var activite: String = ""
    @State private var passions: String = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    var enfantToEdit: Enfant?
    
    init(viewModel: ContentViewModel, enfantToEdit: Enfant? = nil) {
        self.viewModel = viewModel
        self.enfantToEdit = enfantToEdit
        if let enfant = enfantToEdit {
            _prenom = State(initialValue: enfant.prenom)
            _age = State(initialValue: String(enfant.age))
            _activite = State(initialValue: enfant.activite)
            _passions = State(initialValue: enfant.passions)
            if let photoData = enfant.photo, let image = UIImage(data: photoData) {
                _selectedImage = State(initialValue: image)
            }
        }
    }
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .center, spacing: 20) {
                    // Photo de profil
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.primaryPurple, lineWidth: 3))
                        } else {
                            ZStack {
                                Circle()
                                    .fill(Color.primaryPurple.opacity(0.1))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.primaryPurple)
                            }
                        }
                    }
                    
                    Text(localization.localizedString("form.photo"))
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }
            
            Section {
                TextField(localization.localizedString("form.firstName.placeholder"), text: $prenom)
                HStack {
                    TextField(localization.localizedString("form.age.placeholder"), text: $age)
                        .keyboardType(.numberPad)
                    Text(localization.localizedString("form.age.years"))
                        .foregroundColor(.textSecondary)
                }
                TextField(localization.localizedString("form.activity.placeholder"), text: $activite)
                TextField(localization.localizedString("form.passions.placeholder"), text: $passions)
            }
        }
        .navigationTitle(enfantToEdit != nil ? localization.localizedString("form.save") : localization.localizedString("form.title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: sauvegarderProfil) {
                    Text(enfantToEdit != nil ? localization.localizedString("form.save") : localization.localizedString("form.button"))
                        .bold()
                }
                .disabled(prenom.isEmpty || age.isEmpty || activite.isEmpty || passions.isEmpty)
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
    
    private func sauvegarderProfil() {
        let photoData = selectedImage?.jpegData(compressionQuality: 0.7)
        let enfant = Enfant(
            id: enfantToEdit?.id ?? UUID(),
            prenom: prenom,
            age: Int(age) ?? 0,
            activite: activite,
            passions: passions,
            photo: photoData,
            histoires: enfantToEdit?.histoires ?? []
        )
        
        EnfantService.sauvegarderEnfant(enfant)
        viewModel.chargerEnfants()
        dismiss()
    }
}

struct FormFieldView: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.primaryPurple.opacity(0.1))
                        .frame(width: 30, height: 30)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(.primaryPurple)
                }
                
                Text(title)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
            }
            
            TextField(placeholder, text: $text)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.textPrimary)
                .accentColor(.primaryPurple)
                .textFieldStyle(CustomTextFieldStyle())
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primaryPurple.opacity(0.2), lineWidth: 1)
            )
    }
}

#Preview {
    FormView(viewModel: ContentViewModel())
} 