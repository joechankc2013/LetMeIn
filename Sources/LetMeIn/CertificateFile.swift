//
//  CertificateFile.swift
//  LetMeIn
//

import Foundation

/// A representation of a certificate file
public struct CertificateFile: HasLogger {
    
    // MARK: - Public Properties
    
    /// The type of certificate, defaults to `pkcs12` if not specified
    public var type: CertificateType = .pkcs12
    
    /// The certificate's file name (must be inside the app bundle)
    public var fileName: String
    
    /// The file extension for the certificate, defaults to `pfx` if not specified
    public var fileExtension: String = "pfx"
    
    /// The certificate's password, used to read the certificate
    public var password: String
    
    // MARK: - Private Properties
    
    /// The URL of the certificate file
    private var url: URL? {
        let url = Bundle(for: ClientCertificateAuthenticator.self).url(forResource: fileName, withExtension: fileExtension)
        if url == nil {
            logger.critical("Certificate File Does Not Exist")
        }
        return url
    }
    
    // MARK: - Internal Methods
    
    /// Creates a certificate representation from file data
    /// - Parameter data: The certificate data
    /// - Returns: The representation
    func createCertificate() -> Certificate? {
        guard let data = getData() else { return nil }
        return type.representationType.init(data: data, password: password)
    }
    
    // MARK: - Private Methods
    
    /// Gets the certificate file's data
    /// - Returns: The certificate's data
    private func getData() -> Data? {
        guard let url = url else {
            return nil
        }
        
        guard url.isFileURL else {
            logger.critical("Remote certificate files are not supported")
            fatalError("[ClientCertificateAuthenticator] Illegal request: Remote certificate files are not supported")
        }
        
        do {
            return try Data(contentsOf: url)
        } catch {
            logger.critical("Failed to read certificate file (Error: \(error.localizedDescription))")
            return nil
        }
    }
}
