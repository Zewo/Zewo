//public enum JSONType : String {
//    case object = "object"
//    case array = "array"
//    case string = "string"
//    case integer = "integer"
//    case number = "number"
//    case boolean = "boolean"
//    case null = "null"
//}
//
//extension String {
//    func stringByRemovingPrefix(_ prefix: String) -> String? {
//        if hasPrefix(prefix) {
//            let index = characters.index(startIndex, offsetBy: prefix.characters.count)
//            return substring(from: index)
//        }
//        
//        return nil
//    }
//}
//
//public struct Schema {
//    public let title: String?
//    public let description: String?
//    
//    public let type: [JSONType]?
//    
//    let formats: [String: Validator]
//    
//    let schema: [String: Any]
//    
//    public init(_ schema: JSON) {
//        title = try? schema.get("title")
//        description = try? schema.get("description")
//        
//        if let type = try? schema.get("type") as String {
//            if let type = JSONType(rawValue: type) {
//                self.type = [type]
//            } else {
//                self.type = []
//            }
//        } else if let types = try? schema.get("type") as [String] {
//            self.type = types.map { Type(rawValue: $0) }.filter { $0 != nil }.map { $0! }
//        } else {
//            self.type = []
//        }
//        
//        self.schema = schema
//        
//        formats = [
//            "ipv4": validateIPv4,
//            "ipv6": validateIPv6,
//        ]
//    }
//    
//    public func validate(_ data:Any) -> ValidationResult {
//        let validator = allOf(validators(self)(schema))
//        let result = validator(data)
//        return result
//    }
//    
//    func validatorForReference(_ reference:String) -> Validator {
//        // TODO: Rewrite this whole block: https://github.com/kylef/JSONSchema.swift/issues/12
//        if let reference = reference.stringByRemovingPrefix("#") {  // Document relative
//            if let tmp = reference.stringByRemovingPrefix("/"), let reference = (tmp as NSString).removingPercentEncoding {
//                var components = reference.components(separatedBy: "/")
//                var schema = self.schema
//                while let component = components.first {
//                    components.remove(at: components.startIndex)
//                    
//                    if let subschema = schema[component] as? [String:Any] {
//                        schema = subschema
//                        continue
//                    } else if let schemas = schema[component] as? [[String:Any]] {
//                        if let component = components.first, let index = Int(component) {
//                            components.remove(at: components.startIndex)
//                            
//                            if schemas.count > index {
//                                schema = schemas[index]
//                                continue
//                            }
//                        }
//                    }
//                    
//                    return invalidValidation("Reference not found '\(component)' in '\(reference)'")
//                }
//                
//                return allOf(JSONSchema.validators(self)(schema))
//            } else if reference == "" {
//                return { value in
//                    let validators = JSONSchema.validators(self)(self.schema)
//                    return allOf(validators)(value)
//                }
//            }
//        }
//        
//        return invalidValidation("Remote $ref '\(reference)' is not yet supported")
//    }
//}
//
///// Returns a set of validators for a schema and document
//func validators(_ root: Schema) -> (_ schema: [String:Any]) -> [Validator] {
//    return { schema in
//        var validators = [Validator]()
//        
//        if let ref = schema["$ref"] as? String {
//            validators.append(root.validatorForReference(ref))
//        }
//        
//        if let type = schema["type"] {
//            // Rewrite this and most of the validator to use the `type` property, see https://github.com/kylef/JSONSchema.swift/issues/12
//            validators.append(validateType(type))
//        }
//        
//        if let allOf = schema["allOf"] as? [[String:Any]] {
//            validators += allOf.map(JSONSchema.validators(root)).reduce([], +)
//        }
//        
//        if let anyOfSchemas = schema["anyOf"] as? [[String:Any]] {
//            let anyOfValidators = anyOfSchemas.map(JSONSchema.validators(root)).map(allOf) as [Validator]
//            validators.append(anyOf(anyOfValidators))
//        }
//        
//        if let oneOfSchemas = schema["oneOf"] as? [[String:Any]] {
//            let oneOfValidators = oneOfSchemas.map(JSONSchema.validators(root)).map(allOf) as [Validator]
//            validators.append(oneOf(oneOfValidators))
//        }
//        
//        if let notSchema = schema["not"] as? [String:Any] {
//            let notValidator = allOf(JSONSchema.validators(root)(notSchema))
//            validators.append(not(notValidator))
//        }
//        
//        if let enumValues = schema["enum"] as? [Any] {
//            validators.append(validateEnum(enumValues))
//        }
//        
//        // String
//        if let maxLength = schema["maxLength"] as? Int {
//            validators.append(validateLength(<=, length: maxLength, error: "Length of string is larger than max length \(maxLength)"))
//        }
//        
//        if let minLength = schema["minLength"] as? Int {
//            validators.append(validateLength(>=, length: minLength, error: "Length of string is smaller than minimum length \(minLength)"))
//        }
//        
//        if let pattern = schema["pattern"] as? String {
//            validators.append(validatePattern(pattern))
//        }
//        
//        // Numerical
//        if let multipleOf = schema["multipleOf"] as? Double {
//            validators.append(validateMultipleOf(multipleOf))
//        }
//        
//        if let minimum = schema["minimum"] as? Double {
//            validators.append(validateNumericLength(minimum, comparitor: >=, exclusiveComparitor: >, exclusive: schema["exclusiveMinimum"] as? Bool, error: "Value is lower than minimum value of \(minimum)"))
//        }
//        
//        if let maximum = schema["maximum"] as? Double {
//            validators.append(validateNumericLength(maximum, comparitor: <=, exclusiveComparitor: <, exclusive: schema["exclusiveMaximum"] as? Bool, error: "Value exceeds maximum value of \(maximum)"))
//        }
//        
//        // Array
//        if let minItems = schema["minItems"] as? Int {
//            validators.append(validateArrayLength(minItems, comparitor: >=, error: "Length of array is smaller than the minimum \(minItems)"))
//        }
//        
//        if let maxItems = schema["maxItems"] as? Int {
//            validators.append(validateArrayLength(maxItems, comparitor: <=, error: "Length of array is greater than maximum \(maxItems)"))
//        }
//        
//        if let uniqueItems = schema["uniqueItems"] as? Bool {
//            if uniqueItems {
//                validators.append(validateUniqueItems)
//            }
//        }
//        
//        if let items = schema["items"] as? [String:Any] {
//            let itemsValidators = allOf(JSONSchema.validators(root)(items))
//            
//            func validateItems(_ document:Any) -> ValidationResult {
//                if let document = document as? [Any] {
//                    return flatten(document.map(itemsValidators))
//                }
//                
//                return .Valid
//            }
//            
//            validators.append(validateItems)
//        } else if let items = schema["items"] as? [[String:Any]] {
//            func createAdditionalItemsValidator(_ additionalItems:Any?) -> Validator {
//                if let additionalItems = additionalItems as? [String:Any] {
//                    return allOf(JSONSchema.validators(root)(additionalItems))
//                }
//                
//                let additionalItems = additionalItems as? Bool ?? true
//                if additionalItems {
//                    return validValidation
//                }
//                
//                return invalidValidation("Additional results are not permitted in this array.")
//            }
//            
//            let additionalItemsValidator = createAdditionalItemsValidator(schema["additionalItems"])
//            let itemValidators = items.map(JSONSchema.validators(root))
//            
//            func validateItems(_ value:Any) -> ValidationResult {
//                if let value = value as? [Any] {
//                    var results = [ValidationResult]()
//                    
//                    for (index, element) in value.enumerated() {
//                        if index >= itemValidators.count {
//                            results.append(additionalItemsValidator(element))
//                        } else {
//                            let validators = allOf(itemValidators[index])
//                            results.append(validators(element))
//                        }
//                    }
//                    
//                    return flatten(results)
//                }
//                
//                return .Valid
//            }
//            
//            validators.append(validateItems)
//        }
//        
//        if let maxProperties = schema["maxProperties"] as? Int {
//            validators.append(validatePropertiesLength(maxProperties, comparitor: >=, error: "Amount of properties is greater than maximum permitted"))
//        }
//        
//        if let minProperties = schema["minProperties"] as? Int {
//            validators.append(validatePropertiesLength(minProperties, comparitor: <=, error: "Amount of properties is less than the required amount"))
//        }
//        
//        if let required = schema["required"] as? [String] {
//            validators.append(validateRequired(required))
//        }
//        
//        if (schema["properties"] != nil) || (schema["patternProperties"] != nil) || (schema["additionalProperties"] != nil) {
//            func createAdditionalPropertiesValidator(_ additionalProperties:Any?) -> Validator {
//                if let additionalProperties = additionalProperties as? [String:Any] {
//                    return allOf(JSONSchema.validators(root)(additionalProperties))
//                }
//                
//                let additionalProperties = additionalProperties as? Bool ?? true
//                if additionalProperties {
//                    return validValidation
//                }
//                
//                return invalidValidation("Additional properties are not permitted in this object.")
//            }
//            
//            func createPropertiesValidators(_ properties:[String:[String:Any]]?) -> [String:Validator]? {
//                if let properties = properties {
//                    return Dictionary(properties.keys.map {
//                        key in (key, allOf(JSONSchema.validators(root)(properties[key]!)))
//                    })
//                }
//                
//                return nil
//            }
//            
//            let additionalPropertyValidator = createAdditionalPropertiesValidator(schema["additionalProperties"])
//            let properties = createPropertiesValidators(schema["properties"] as? [String:[String:Any]])
//            let patternProperties = createPropertiesValidators(schema["patternProperties"] as? [String:[String:Any]])
//            validators.append(validateProperties(properties, patternProperties: patternProperties, additionalProperties: additionalPropertyValidator))
//        }
//        
//        func validateDependency(_ key: String, validator: @escaping Validator) -> (_ value: Any) -> ValidationResult {
//            return { value in
//                if let value = value as? [String:Any] {
//                    if (value[key] != nil) {
//                        return validator(value)
//                    }
//                }
//                
//                return .Valid
//            }
//        }
//        
//        func validateDependencies(_ key: String, dependencies: [String]) -> (_ value: Any) -> ValidationResult {
//            return { value in
//                if let value = value as? [String:Any] {
//                    if (value[key] != nil) {
//                        return flatten(dependencies.map { dependency in
//                            if value[dependency] == nil {
//                                return .invalid(["'\(key)' is missing it's dependency of '\(dependency)'"])
//                            }
//                            return .Valid
//                        })
//                    }
//                }
//                
//                return .Valid
//            }
//        }
//        
//        if let dependencies = schema["dependencies"] as? [String:Any] {
//            for (key, dependencies) in dependencies {
//                if let dependencies = dependencies as? [String: Any] {
//                    let schema = allOf(JSONSchema.validators(root)(dependencies))
//                    validators.append(validateDependency(key, validator: schema))
//                } else if let dependencies = dependencies as? [String] {
//                    validators.append(validateDependencies(key, dependencies: dependencies))
//                }
//            }
//        }
//        
//        if let format = schema["format"] as? String {
//            if let validator = root.formats[format] {
//                validators.append(validator)
//            } else {
//                validators.append(invalidValidation("'format' validation of '\(format)' is not yet supported."))
//            }
//        }
//        
//        return validators
//    }
//}
//
//public func validate(_ value:Any, schema:[String:Any]) -> ValidationResult {
//    let root = Schema(schema)
//    let validator = allOf(validators(root)(schema))
//    let result = validator(value)
//    return result
//}
//
///// Extension for dictionary providing initialization from array of elements
//extension Dictionary {
//    init(_ pairs: [Element]) {
//        self.init()
//        
//        for (key, value) in pairs {
//            self[key] = value
//        }
//    }
//}
//
//public enum ValidationResult {
//    case Valid
//    case invalid([String])
//    
//    public var valid: Bool {
//        switch self {
//        case .Valid:
//            return true
//        case .invalid:
//            return false
//        }
//    }
//    
//    public var errors:[String]? {
//        switch self {
//        case .Valid:
//            return nil
//        case .invalid(let errors):
//            return errors
//        }
//    }
//}
//
//typealias LegacyValidator = (Any) -> (Bool)
//typealias Validator = (Any) -> (ValidationResult)
//
///// Flatten an array of results into a single result (combining all errors)
//func flatten(_ results:[ValidationResult]) -> ValidationResult {
//    let failures = results.filter { result in !result.valid }
//    if failures.count > 0 {
//        let errors = failures.reduce([String]()) { (accumulator, failure) in
//            if let errors = failure.errors {
//                return accumulator + errors
//            }
//            
//            return accumulator
//        }
//        
//        return .invalid(errors)
//    }
//    
//    return .Valid
//}
//
///// Creates a Validator which always returns an valid result
//func validValidation(_ value:Any) -> ValidationResult {
//    return .Valid
//}
//
///// Creates a Validator which always returns an invalid result with the given error
//func invalidValidation(_ error: String) -> (_ value: Any) -> ValidationResult {
//    return { value in
//        return .invalid([error])
//    }
//}
//
//// MARK: Shared
///// Validate the given value is of the given type
//func validateType(_ type: String) -> (_ value: Any) -> ValidationResult {
//    return { value in
//        switch type {
//        case "integer":
//            if let number = value as? NSNumber {
//                if !CFNumberIsFloatType(number) && CFGetTypeID(number) != CFBooleanGetTypeID() {
//                    return .Valid
//                }
//            }
//        case "number":
//            if let number = value as? NSNumber {
//                if CFGetTypeID(number) != CFBooleanGetTypeID() {
//                    return .Valid
//                }
//            }
//        case "string":
//            if value is String {
//                return .Valid
//            }
//        case "object":
//            if value is NSDictionary {
//                return .Valid
//            }
//        case "array":
//            if value is NSArray {
//                return .Valid
//            }
//        case "boolean":
//            if let number = value as? NSNumber {
//                if CFGetTypeID(number) == CFBooleanGetTypeID() {
//                    return .Valid
//                }
//            }
//        case "null":
//            if value is NSNull {
//                return .Valid
//            }
//        default:
//            break
//        }
//        
//        return .invalid(["'\(value)' is not of type '\(type)'"])
//    }
//}
//
///// Validate the given value is one of the given types
//func validateType(_ type:[String]) -> Validator {
//    let typeValidators = type.map(validateType) as [Validator]
//    return anyOf(typeValidators)
//}
//
//func validateType(_ type:Any) -> Validator {
//    if let type = type as? String {
//        return validateType(type)
//    } else if let types = type as? [String] {
//        return validateType(types)
//    }
//    
//    return invalidValidation("'\(type)' is not a valid 'type'")
//}
//
//
///// Validate that a value is valid for any of the given validation rules
//func anyOf(_ validators:[Validator], error:String? = nil) -> (_ value: Any) -> ValidationResult {
//    return { value in
//        for validator in validators {
//            let result = validator(value)
//            if result.valid {
//                return .Valid
//            }
//        }
//        
//        if let error = error {
//            return .invalid([error])
//        }
//        
//        return .invalid(["\(value) does not meet anyOf validation rules."])
//    }
//}
//
//func oneOf(_ validators: [Validator]) -> (_ value: Any) -> ValidationResult {
//    return { value in
//        let results = validators.map { validator in validator(value) }
//        let validValidators = results.filter { $0.valid }.count
//        
//        if validValidators == 1 {
//            return .Valid
//        }
//        
//        return .invalid(["\(validValidators) validates instead `oneOf`."])
//    }
//}
//
///// Creates a validator that validates that the given validation rules are not met
//func not(_ validator: @escaping Validator) -> (_ value: Any) -> ValidationResult {
//    return { value in
//        if validator(value).valid {
//            return .invalid(["'\(value)' does not match 'not' validation."])
//        }
//        
//        return .Valid
//    }
//}
//
//func allOf(_ validators: [Validator]) -> (_ value: Any) -> ValidationResult {
//    return { value in
//        return flatten(validators.map { validator in validator(value) })
//    }
//}
//
//func validateEnum(_ values: [Any]) -> (_ value: Any) -> ValidationResult {
//    return { value in
//        if (values as! [NSObject]).contains(value as! NSObject) {
//            return .Valid
//        }
//        
//        return .invalid(["'\(value)' is not a valid enumeration value of '\(values)'"])
//    }
//}
//
//// MARK: String
//func validateLength(_ comparitor: @escaping ((Int, Int) -> (Bool)), length: Int, error: String) -> (_ value: Any) -> ValidationResult {
//    return { value in
//        if let value = value as? String {
//            if !comparitor(value.characters.count, length) {
//                return .invalid([error])
//            }
//        }
//        
//        return .Valid
//    }
//}
//
//func validatePattern(_ pattern: String) -> (_ value: Any) -> ValidationResult {
//    return { value in
//        if let value = value as? String {
//            let expression = try? NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue: 0))
//            if let expression = expression {
//                let range = NSMakeRange(0, value.characters.count)
//                if expression.matches(in: value, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: range).count == 0 {
//                    return .invalid(["'\(value)' does not match pattern: '\(pattern)'"])
//                }
//            } else {
//                return .invalid(["[Schema] Regex pattern '\(pattern)' is not valid"])
//            }
//        }
//        
//        return .Valid
//    }
//}
//
//// MARK: Numerical
//func validateMultipleOf(_ number: Double) -> (_ value: Any) -> ValidationResult {
//    return { value in
//        if number > 0.0 {
//            if let value = value as? Double {
//                let result = value / number
//                if result != floor(result) {
//                    return .invalid(["\(value) is not a multiple of \(number)"])
//                }
//            }
//        }
//        
//        return .Valid
//    }
//}
//
//func validateNumericLength(_ length: Double, comparitor: @escaping ((Double, Double) -> (Bool)), exclusiveComparitor: @escaping ((Double, Double) -> (Bool)), exclusive: Bool?, error: String) -> (_ value: Any) -> ValidationResult {
//    return { value in
//        if let value = value as? Double {
//            if exclusive ?? false {
//                if !exclusiveComparitor(value, length) {
//                    return .invalid([error])
//                }
//            }
//            
//            if !comparitor(value, length) {
//                return .invalid([error])
//            }
//        }
//        
//        return .Valid
//    }
//}
//
//// MARK: Array
//func validateArrayLength(_ rhs: Int, comparitor: @escaping ((Int, Int) -> Bool), error: String) -> (_ value: Any) -> ValidationResult {
//    return { value in
//        if let value = value as? [Any] {
//            if !comparitor(value.count, rhs) {
//                return .invalid([error])
//            }
//        }
//        
//        return .Valid
//    }
//}
//
//func validateUniqueItems(_ value: Any) -> ValidationResult {
//    if let value = value as? [Any] {
//        // 1 and true, 0 and false are isEqual for NSNumber's, so logic to count for that below
//        func isBoolean(_ number:NSNumber) -> Bool {
//            return CFGetTypeID(number) != CFBooleanGetTypeID()
//        }
//        
//        let numbers = value.filter { value in value is NSNumber } as! [NSNumber]
//        let numerBooleans = numbers.filter(isBoolean)
//        let booleans = numerBooleans as [Bool]
//        let nonBooleans = numbers.filter { number in !isBoolean(number) }
//        let hasTrueAndOne = booleans.filter { v in v }.count > 0 && nonBooleans.filter { v in v == 1 }.count > 0
//        let hasFalseAndZero = booleans.filter { v in !v }.count > 0 && nonBooleans.filter { v in v == 0 }.count > 0
//        let delta = (hasTrueAndOne ? 1 : 0) + (hasFalseAndZero ? 1 : 0)
//        
//        if (NSSet(array: value).count + delta) == value.count {
//            return .Valid
//        }
//        
//        return .invalid(["\(value) does not have unique items"])
//    }
//    
//    return .Valid
//}
//
//// MARK: object
//func validatePropertiesLength(_ length: Int, comparitor: @escaping ((Int, Int) -> (Bool)), error: String) -> (_ value: Any)  -> ValidationResult {
//    return { value in
//        if let value = value as? [String:Any] {
//            if !comparitor(length, value.count) {
//                return .invalid([error])
//            }
//        }
//        
//        return .Valid
//    }
//}
//
//func validateRequired(_ required: [String]) -> (_ value: Any)  -> ValidationResult {
//    return { value in
//        if let value = value as? [String:Any] {
//            if (required.filter { r in !value.keys.contains(r) }.count == 0) {
//                return .Valid
//            }
//            
//            return .invalid(["Required properties are missing '\(required)'"])
//        }
//        
//        return .Valid
//    }
//}
//
//func validateProperties(_ properties: [String:Validator]?, patternProperties: [String:Validator]?, additionalProperties: Validator?) -> (_ value: Any) -> ValidationResult {
//    return { value in
//        if let value = value as? [String:Any] {
//            let allKeys = NSMutableSet()
//            var results = [ValidationResult]()
//            
//            if let properties = properties {
//                for (key, validator) in properties {
//                    allKeys.add(key)
//                    
//                    if let value: Any = value[key] {
//                        results.append(validator(value))
//                    }
//                }
//            }
//            
//            if let patternProperties = patternProperties {
//                for (pattern, validator) in patternProperties {
//                    do {
//                        let expression = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue: 0))
//                        let keys = value.keys.filter {
//                            (key: String) in expression.matches(in: key, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, key.characters.count)).count > 0
//                        }
//                        
//                        allKeys.addObjects(from: Array(keys))
//                        results += keys.map { key in validator(value[key]!) }
//                    } catch {
//                        return .invalid(["[Schema] '\(pattern)' is not a valid regex pattern for patternProperties"])
//                    }
//                }
//            }
//            
//            if let additionalProperties = additionalProperties {
//                let additionalKeys = value.keys.filter { !allKeys.contains($0) }
//                results += additionalKeys.map { key in additionalProperties(value[key]!) }
//            }
//            
//            return flatten(results)
//        }
//        
//        return .Valid
//    }
//}
//
//func validateDependency(_ key: String, validator: @escaping LegacyValidator) -> (_ value: Any) -> Bool {
//    return { value in
//        if let value = value as? [String:Any] {
//            if (value[key] != nil) {
//                return validator(value as Any)
//            }
//        }
//        
//        return true
//    }
//}
//
//func validateDependencies(_ key: String, dependencies: [String]) -> (_ value: Any) -> Bool {
//    return { value in
//        if let value = value as? [String:Any] {
//            if (value[key] != nil) {
//                for dependency in dependencies {
//                    if (value[dependency] == nil) {
//                        return false
//                    }
//                }
//            }
//        }
//        
//        return true
//    }
//}
//
//// MARK: Format
//func validateIPv4(_ value:Any) -> ValidationResult {
//    if let ipv4 = value as? String {
//        if let expression = try? NSRegularExpression(pattern: "^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", options: NSRegularExpression.Options(rawValue: 0)) {
//            if expression.matches(in: ipv4, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, ipv4.characters.count)).count == 1 {
//                return .Valid
//            }
//        }
//        
//        return .invalid(["'\(ipv4)' is not valid IPv4 address."])
//    }
//    
//    return .Valid
//}
//
//func validateIPv6(_ value:Any) -> ValidationResult {
//    if let ipv6 = value as? String {
//        var buf = UnsafeMutablePointer<Int8>.allocate(capacity: Int(INET6_ADDRSTRLEN))
//        if inet_pton(AF_INET6, ipv6, &buf) == 1 {
//            return .Valid
//        }
//        
//        return .invalid(["'\(ipv6)' is not valid IPv6 address."])
//    }
//    
//    return .Valid
//}
