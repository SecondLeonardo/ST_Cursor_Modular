import SwiftUI
import PhotosUI

struct ProfilePictureView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingActionSheet = false
    @State private var showingCropView = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
            // Profile picture section
            profilePictureSection
            
            Spacer()
            
            // Bottom button
            bottomButtonSection
        }
        .navigationTitle("Profile Picture")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selectedImage = coordinator.onboardingData.profilePicture
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showingCamera) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
        }
        .sheet(isPresented: $showingCropView) {
            if let image = selectedImage {
                ImageCropView(image: image) { croppedImage in
                    selectedImage = croppedImage
                    coordinator.onboardingData.profilePicture = croppedImage
                }
            }
        }
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(
                title: Text("Add Profile Picture"),
                message: Text("Choose how you want to add your profile picture"),
                buttons: [
                    .default(Text("Take Photo")) {
                        showingCamera = true
                    },
                    .default(Text("Choose from Library")) {
                        showingImagePicker = true
                    },
                    .cancel()
                ]
            )
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Add a profile picture")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(ThemeColors.primary)
            
            Text("Last step! A real photo helps others get to know you better.")
                .font(.body)
                .foregroundColor(ThemeColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }
    
    // MARK: - Profile Picture Section
    private var profilePictureSection: some View {
        VStack(spacing: 24) {
            // Profile picture circle
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 200, height: 200)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 180, height: 180)
                        .clipShape(Circle())
                        .onTapGesture {
                            showingActionSheet = true
                        }
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 80))
                        .foregroundColor(ThemeColors.textSecondary)
                        .onTapGesture {
                            showingActionSheet = true
                        }
                }
                
                // Add button
                Button(action: {
                    showingActionSheet = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(ThemeColors.primary)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .offset(x: 60, y: 60)
            }
            
            // Instructions
            if selectedImage == nil {
                VStack(spacing: 8) {
                    Text("Tap the + button to add your photo")
                        .font(.subheadline)
                        .foregroundColor(ThemeColors.textSecondary)
                    
                    Text("A clear, friendly photo works best!")
                        .font(.caption)
                        .foregroundColor(ThemeColors.textSecondary)
                }
            } else {
                VStack(spacing: 8) {
                    Text("Great! Your profile picture is set")
                        .font(.subheadline)
                        .foregroundColor(ThemeColors.success)
                    
                    Button("Change Photo") {
                        showingActionSheet = true
                    }
                    .font(.caption)
                    .foregroundColor(ThemeColors.primary)
                }
            }
        }
    }
    
    // MARK: - Bottom Button Section
    private var bottomButtonSection: some View {
        VStack(spacing: 16) {
            PrimaryButton(
                title: "Start Learning",
                action: {
                    coordinator.onboardingData.profilePicture = selectedImage
                    coordinator.nextStep()
                }
            )
            .disabled(selectedImage == nil)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: -4)
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage {
                parent.selectedImage = image
            } else if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Image Crop View
struct ImageCropView: View {
    let image: UIImage
    let onCrop: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var offset = CGSize.zero
    @State private var lastOffset = CGSize.zero
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Instructions
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow)
                            Text("A real and clear profile picture is key to finding Skill partners.")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        
                        Text("To ensure optimal picture display, please place the main subject in the dotted lines.")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal, 20)
                    
                    // Image with crop overlay
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            )
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        scale = value
                                    }
                            )
                        
                        // Crop circle overlay
                        Circle()
                            .stroke(Color.white, style: StrokeStyle(lineWidth: 2, dash: [5]))
                            .frame(width: 200, height: 200)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Spacer()
                }
            }
            .navigationTitle("Crop Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("OK") {
                        // Crop the image to the circle
                        if let croppedImage = cropImageToCircle(image) {
                            onCrop(croppedImage)
                        }
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private func cropImageToCircle(_ image: UIImage) -> UIImage? {
        // Simple implementation - in a real app you'd want more sophisticated cropping
        let size = CGSize(width: 200, height: 200)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        let rect = CGRect(origin: .zero, size: size)
        let path = UIBezierPath(ovalIn: rect)
        path.addClip()
        
        image.draw(in: rect)
        
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return croppedImage
    }
}

#Preview {
    NavigationView {
        ProfilePictureView(coordinator: OnboardingCoordinator())
    }
} 