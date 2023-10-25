/*
Copyright (c) 2023 European Commission

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import Foundation
import MdocDataModel18013
import SwiftUI
import Logging

public class DataSampleStorageService: ObservableObject, DataStorageService {
	
	@Published public var euPidModel: EuPidModel?
	@Published public var isoMdlModel: IsoMdlModel?
	var sampleData: Data?
	@AppStorage("pidLoaded") public var pidLoaded: Bool = false
	@AppStorage("mdlLoaded") public var mdlLoaded: Bool = false
	@AppStorage("DebugDisplay") var debugDisplay: Bool = false
	let logger: Logger

	public init() {
		logger = Logger(label: "logger")
	}

	public func getDoc(i: Int) -> MdocDecodable? { i == 0 ? euPidModel : isoMdlModel}
	public func removeDoc(i: Int) {
		if i == 0 { euPidModel = nil; pidLoaded = false }
		else { isoMdlModel = nil; mdlLoaded = false }
	}
	
	public var hasData: Bool { pidLoaded && getDoc(i: 0) != nil || mdlLoaded && getDoc(i: 1) != nil }
	
	public func loadSampleData(force: Bool = false) {
		debugDisplay = true
		guard let sd = try? loadDocument(id: Self.defaultId) else { return }
		let sr = sd.decodeJSON(type: SignUpResponse.self)!
		guard let dr = sr.deviceResponse, let dpk = sr.devicePrivateKey else { return }
		if force || pidLoaded { euPidModel = EuPidModel(response: dr, devicePrivateKey: dpk) }
		pidLoaded = euPidModel != nil
		if force || mdlLoaded { isoMdlModel = IsoMdlModel(response: dr, devicePrivateKey: dpk) }
		mdlLoaded = isoMdlModel != nil
	}
	
	public static var defaultId: String = "EUDI_sample_data"
	
	public func loadDocument(id: String) throws -> Data {
		if let sampleData { return sampleData }
		sampleData = Data(name: id) ?? Data()
		return sampleData!
	}
	
	public func saveDocument(id: String, value: inout Data) throws {
	}
	
	public func deleteDocument(id: String) throws {
	}
}
