//
//  AssignmentRowView.swift
//  GroupLeader
//
//  Created by Gavin Normand on 7/12/26.
//

import SwiftUI

struct AssignmentRowView: View {
    @Binding var assignment: NewPostView.AssignmentDraft
    let members: [UserModel]
    let metrics: [MetricModel]
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Menu {
                    ForEach(members) { member in
                        Button(member.username) {
                            assignment.recipient = member
                        }
                    }
                } label: {
                    HStack {
                        Text(assignment.recipient?.username ?? "Who")
                            .font(.subheadline)
                            .foregroundStyle(assignment.recipient == nil ? .secondary : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                Menu {
                    ForEach(metrics) { metric in
                        Button(metric.name) {
                            assignment.metric = metric
                        }
                    }
                } label: {
                    HStack {
                        Text(assignment.metric?.name ?? "Metric")
                            .font(.subheadline)
                            .foregroundStyle(assignment.metric == nil ? .secondary : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.title3)
                }
            }

            HStack {
                Text("Points")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    assignment.value -= 1
                } label: {
                    Image(systemName: "minus.circle")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                Text(assignment.value > 0 ? "+\(assignment.value)" : "\(assignment.value)")
                    .font(.subheadline.monospacedDigit())
                    .fontWeight(.medium)
                    .foregroundStyle(assignment.value > 0 ? .green : assignment.value < 0 ? .red : .secondary)
                    .frame(minWidth: 40, alignment: .center)
                Button {
                    assignment.value += 1
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    AssignmentRowView(
        assignment: .constant(NewPostView.AssignmentDraft()),
        members: [],
        metrics: [],
        onDelete: {}
    )
    .padding()
}
