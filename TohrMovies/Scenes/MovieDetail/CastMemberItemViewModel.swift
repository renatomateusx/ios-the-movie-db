//
//  CastMemberItemViewModel.swift
//  TohrMovies
//
//  Created by Renato Mateus on 05/03/21.
//

import UIKit
public struct CastMemberItemViewModel {
    private let member: MovieCast
    
    init (withMember member: MovieCast){
        self.member = member
    }
    
    var profileImageURL: URL? {
        if let path = member.profilePath {
            return URL(string: "https://image.tmdb.org/t/p/h632//\(path)")
        }
        return nil
    }
    
    var nameInitials: String {
        let initials = self.member.name.components(separatedBy: " ").reduce("") { (string, nextWord) -> String in
            guard nextWord.count > 0 else { return string }
            return string + nextWord.prefix(1).uppercased()
        }
        return String(initials.prefix(3))
    }
    
    var characterName: String? {
        return member.character
    }
    
    var name: String? {
        return member.name
    }
}
