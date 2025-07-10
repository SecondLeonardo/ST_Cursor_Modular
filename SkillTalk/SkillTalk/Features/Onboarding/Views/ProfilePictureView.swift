import SwiftUI
import PhotosUI

struct ProfilePictureView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingActionSheet = false
    @State private var showingCropView = false
    // Add a temp image to hold the image to crop
    @State private var imageToCrop: UIImage?
    
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
            ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary, onImagePicked: { image in
                imageToCrop = image
                showingCropView = true
            })
        }
        .sheet(isPresented: $showingCamera) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .camera, onImagePicked: { image in
                imageToCrop = image
                showingCropView = true
            })
        }
        .sheet(isPresented: $showingCropView) {
            if let image = imageToCrop {
                ImageCropView(image: image) { croppedImage in
                    selectedImage = croppedImage
                    coordinator.onboardingData.profilePicture = croppedImage
                    showingCropView = false
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
                        .font(.system(size: 16, weight: .semibold))
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
    var onImagePicked: ((UIImage) -> Void)? = nil
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
                parent.onImagePicked?(image)
            } else if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                parent.onImagePicked?(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Enhanced Image Crop View
struct ImageCropView: View {
    let image: UIImage
    let onCrop: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var offset = CGSize.zero
    @State private var lastOffset = CGSize.zero
    @State private var rotation: Angle = .zero
    @State private var isFlippedH = false
    @State private var isFlippedV = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Spacer(minLength: 20)
                ZStack {
                    // Background
                    Color.black.opacity(0.8).ignoresSafeArea()
                    // Crop area
                    GeometryReader { geo in
                        ZStack {
                            // Image with transforms
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(scale)
                                .rotationEffect(rotation)
                                .scaleEffect(x: isFlippedH ? -1 : 1, y: isFlippedV ? -1 : 1)
                                .offset(offset)
                                .frame(width: geo.size.width, height: geo.size.width)
                                .clipShape(Circle())
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            offset = CGSize(width: lastOffset.width + value.translation.width, height: lastOffset.height + value.translation.height)
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
                                        .onEnded { value in
                                            scale = max(0.5, min(value, 4.0))
                                        }
                                )
                            // Circular mask overlay
                            Circle()
                                .strokeBorder(Color.white.opacity(0.8), lineWidth: 2)
                                .frame(width: geo.size.width, height: geo.size.width)
                            // Grid overlay
                            ForEach(1..<3) { i in
                                Circle()
                                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                                    .frame(width: geo.size.width * CGFloat(i) / 3, height: geo.size.width * CGFloat(i) / 3)
                            }
                        }
                        .frame(width: geo.size.width, height: geo.size.width)
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: 350, maxHeight: 350)
                }
                // Control panel
                HStack(spacing: 24) {
                    Button(action: { scale = min(scale + 0.1, 4.0) }) {
                        Image(systemName: "plus.magnifyingglass")
                    }
                    Button(action: { scale = max(scale - 0.1, 0.5) }) {
                        Image(systemName: "minus.magnifyingglass")
                    }
                    Button(action: { rotation += .degrees(90) }) {
                        Image(systemName: "rotate.right")
                    }
                    Button(action: { isFlippedH.toggle() }) {
                        Image(systemName: "arrow.left.and.right.righttriangle.left.righttriangle.right")
                    }
                    Button(action: { isFlippedV.toggle() }) {
                        Image(systemName: "arrow.up.and.down.righttriangle.up.righttriangle.down")
                    }
                    Button(action: {
                        // Reset
                        scale = 1.0
                        offset = .zero
                        lastOffset = .zero
                        rotation = .zero
                        isFlippedH = false
                        isFlippedV = false
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.black.opacity(0.7))
                .clipShape(Capsule())
                .padding(.bottom, 16)
                // Crop button
                Button(action: {
                    let cropped = cropImage()
                    onCrop(cropped)
                    dismiss()
                }) {
                    Text("Crop & Use Photo")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(ThemeColors.primary)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    // Crop the image to a circle with current transforms
    private func cropImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 400))
        return renderer.image { ctx in
            ctx.cgContext.translateBy(x: 200, y: 200)
            ctx.cgContext.rotate(by: CGFloat(rotation.radians))
            ctx.cgContext.scaleBy(x: isFlippedH ? -scale : scale, y: isFlippedV ? -scale : scale)
            ctx.cgContext.translateBy(x: -200 + offset.width, y: -200 + offset.height)
            let rect = CGRect(x: 0, y: 0, width: 400, height: 400)
            UIBezierPath(ovalIn: rect).addClip()
            image.draw(in: rect)
        }
    }
}

#Preview {
    NavigationView {
        ProfilePictureView(coordinator: OnboardingCoordinator())
    }
} 