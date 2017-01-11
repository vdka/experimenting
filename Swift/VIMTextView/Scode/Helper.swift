//
//  Helper.swift
//  Scode
//
//  Created by Ethan Jackwitz on 6/17/16.
//  Copyright © 2016 Ethan Jackwitz. All rights reserved.
//

func inSequence<A>(_ s: [(A) -> Void]) -> (A) -> Void {
  return { v in
    for f in s {
      f(v)
    }
  }
}
