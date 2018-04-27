//
//  ModalViewControllerDelegate.swift
//  News App
//
//  Created by Richard Richard on 7/26/17.
//  Copyright © 2017 Richard. All rights reserved.
//

import Foundation

protocol ModalViewControllerDelegate
{
    func sendLocationFilter(locationFilter: String)
    func sendCategoryFilter(categoryFilter: String)
}
