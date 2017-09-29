
import UIKit

// The view to edit a color component.
public class MSColorComponentView: UIControl, UITextFieldDelegate {

    // Temporary disabled the color component editing via text field
    let COLOR_TEXT_FIELD_ENABLED: Bool = false

    let MSColorComponentViewSpacing: CGFloat = 5.0
    let MSColorComponentLabelWidth: CGFloat = 60.0
    let MSColorComponentTextFieldWidth: CGFloat = 50.0

    // The title.
    var title: String {
        get {
            return label.text ?? ""
        }
        set {
            label.text = newValue
        }
    }

    // The current value. The default value is 0.0.
    var value: CGFloat {
        get {
            return slider.value
        }
        set {
            slider.setValue(value: newValue)
            textField.text = String(format: format, value)
        }
    }

    // The minimum value. The default value is 0.0.
    var minimumValue: CGFloat {
        get {
            return slider.minimumValue
        }
        set {
            slider.minimumValue = newValue
        }
    }

    // The maximum value. The default value is 255.0.
    var maximumValue: CGFloat {
        get {
            return slider.maximumValue
        }
        set {
            slider.maximumValue = newValue
        }
    }

    // The format string to use apply for textfield value. \c %.f by default.
    var format: String = "%.f"

    private let label: UILabel = UILabel()
    private let slider: MSSliderView = MSSliderView() // The color slider to edit color component.
    private let textField: UITextField = UITextField()

    override open class var requiresConstraintBasedLayout: Bool {
        get {
            return true
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        ms_baseInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        ms_baseInit()
    }

    // MARK:- UITextFieldDelegate methods
    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.value = CGFloat(Double(textField.text ?? "") ?? 0)
        self.sendActions(for: UIControlEvents.valueChanged)
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)
        //first, check if the new string is numeric only. If not, return NO;
        let characterSet = NSCharacterSet(charactersIn: "0123456789,.").inverted
        if !(newString.rangeOfCharacter(from: characterSet)?.isEmpty != false) {
            return false
        }
        return CGFloat(Double(newString) ?? 0) <= slider.maximumValue
    }

    // Sets the array of CGColorRef objects defining the color of each gradient stop on a slider's track.
    // The location of each gradient stop is evaluated with formula: i * width_of_the_track / number_of_colors.
    // @param colors An array of CGColorRef objects.
    func setColors(colors: [CGColor]) {
        if colors.count <= 1 {
            fatalError("‘colors: [CGColor]’ at least need to have 2 elements")
        }

        slider.setColors(colors: colors)
    }

    // MARK:- Private methods
    private func ms_baseInit() {
        self.accessibilityLabel = "color_component_view"

        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        self.addSubview(label)

        slider.maximumValue = MSRGBColorComponentMaxValue
        slider.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(slider)

        if COLOR_TEXT_FIELD_ENABLED {
            textField.borderStyle = UITextBorderStyle.roundedRect
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.keyboardType = UIKeyboardType.numbersAndPunctuation
            self.addSubview(textField)
        }

        self.value = 0.0

        slider.addTarget(self, action: #selector(ms_didChangeSliderValue(sender:)), for: UIControlEvents.valueChanged)
        textField.delegate = self

        self.ms_installConstraints()
    }

    @objc private func ms_didChangeSliderValue(sender: MSSliderView) {
        self.value = sender.value
        self.sendActions(for: UIControlEvents.valueChanged)
    }

    private func ms_installConstraints() {
        if COLOR_TEXT_FIELD_ENABLED {
            let views: [String : Any] = [
                "label" : label,
                "slider" : slider,
                "textField" : textField
            ]
            let metrics: [String : Any] = [
                "spacing" : MSColorComponentViewSpacing,
                "label_width" : MSColorComponentLabelWidth,
                "textfield_width" : MSColorComponentTextFieldWidth
            ]

            self.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|[label(label_width)]-spacing-[slider]-spacing-[textField(textfield_width)]|",
                    options: NSLayoutFormatOptions.alignAllCenterY,
                    metrics: metrics,
                    views: views
                )
            )
            self.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|[label]|",
                    options: NSLayoutFormatOptions(rawValue: 0),
                    metrics: nil,
                    views: views
                )
            )
            self.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|[textField]|",
                    options: NSLayoutFormatOptions(rawValue: 0),
                    metrics: nil,
                    views: views
                )
            )
        } else {
            let views: [String : Any] = [
                "label" : label,
                "slider" : slider
            ]
            let metrics: [String : Any] = [
                "spacing" : MSColorComponentViewSpacing,
                "label_width" : MSColorComponentLabelWidth
            ]
            self.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|[label(label_width)]-spacing-[slider]-spacing-|",
                    options: NSLayoutFormatOptions.alignAllCenterY,
                    metrics: metrics,
                    views: views
                )
            )
            self.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|[label]|",
                    options: NSLayoutFormatOptions(rawValue: 0),
                    metrics: nil,
                    views: views
                )
            )
        }
    }
}
