//
//  NewLocationDelegate.swift
//  MyDivingApp
//
//  Created by aman on 1/5/2024.
//

import Foundation
protocol NewLocationDelegate: NSObject {
    func annotationAdded(annotation: LocationAnnotation)
}
