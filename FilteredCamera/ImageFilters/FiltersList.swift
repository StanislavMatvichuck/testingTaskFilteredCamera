//
//  FiltersList.swift
//  FilteredCamera
//
//  Created by Stanislav Matvichuck on 17.07.2023.
//

import Foundation

struct FiltersList {
    private let filters: [ImageFiltering]

    var availableFiltersNames: [String] { filters.map { $0.description } }

    var selectedFilterIndex: Int { 0 }
    var activeFilter: ImageFiltering { filters[selectedFilterIndex] }

    init(_ filters: [ImageFiltering]) {
        self.filters = filters
    }

    func index(forFilterName: String) -> Int? {
        for (index, filter) in filters.enumerated() {
            if filter.description == forFilterName { return index }
        }

        return nil
    }

    func filter(byName: String) -> ImageFiltering? {
        for filter in filters {
            if filter.description == byName { return filter }
        }

        return nil
    }
}
