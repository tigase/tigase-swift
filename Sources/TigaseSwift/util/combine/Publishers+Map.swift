//
// Publishers+Map.swift
//
// TigaseSwift
// Copyright (C) 2020 "Tigase, Inc." <office@tigase.com>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program. Look for COPYING file in the top folder.
// If not, see http://www.gnu.org/licenses/.
//

import Foundation

extension Publisher {
    
    public func map<ElementOfResult>(_ tranform: @escaping (Output)->ElementOfResult) -> Publishers.Map<Self,ElementOfResult> {
        return .init(upstream: self, transform: tranform);
    }
    
}

extension Publishers {
    
    public struct Map<Upstream: Publisher, Output>: Publisher {
        
        public typealias Failure = Upstream.Failure
        
        public let upstream: Upstream;
        public let transform: (Upstream.Output) -> Output

        public init(upstream: Upstream, transform: @escaping (Upstream.Output)->Output) {
            self.upstream = upstream;
            self.transform = transform;
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Output == S.Input {
            upstream.subscribe(Inner(downstream: subscriber, transform: transform));
        }
        
        private struct Inner<Downstream: Subscriber>: Subscriber where Upstream.Failure == Downstream.Failure {
            
            typealias Input = Upstream.Output
            typealias Failure = Upstream.Failure
            
            private let downstream: Downstream;
            private let transform: (Input)->Downstream.Input;
            
            init(downstream: Downstream, transform: @escaping (Input)->Downstream.Input) {
                self.downstream = downstream;
                self.transform = transform;
            }
            
            func receive(subscription: Subscription) {
                downstream.receive(subscription: subscription);
            }
            
            func receive(completion: Subscribers.Completion<Upstream.Failure>) {
                downstream.receive(completion: completion);
            }
            
            func receive(_ input: Upstream.Output) -> Subscribers.Demand {
                return downstream.receive(transform(input));
            }
        }

    }
}