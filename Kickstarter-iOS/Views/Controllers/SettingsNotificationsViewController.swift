import KsApi
import Library
import Prelude
import UIKit

internal final class SettingsNotificationsViewController: UIViewController {

  private let viewModel: SettingsNotificationsViewModelType = SettingsNotificationsViewModel()

  @IBOutlet fileprivate weak var findFriendsButton: UIButton!
  @IBOutlet fileprivate weak var findFriendsLabel: UILabel!
  @IBOutlet fileprivate weak var followerButton: UIButton!
  @IBOutlet fileprivate weak var friendActivityButton: UIButton!
  @IBOutlet fileprivate weak var friendActivityLabel: UILabel!
  @IBOutlet fileprivate weak var mobileFollowerButton: UIButton!
  @IBOutlet fileprivate weak var mobileFriendActivityButton: UIButton!
  @IBOutlet fileprivate weak var newFollowersLabel: UILabel!
  @IBOutlet fileprivate weak var manageProjectNotificationsButton: UIButton!
  @IBOutlet fileprivate weak var manageProjectNotificationsLabel: UILabel!
  @IBOutlet fileprivate weak var mobileUpdatesButton: UIButton!
  @IBOutlet fileprivate weak var projectNotificationsCountView: CountBadgeView!
  @IBOutlet fileprivate weak var projectsYouBackTitleLabel: UILabel!
  @IBOutlet fileprivate weak var projectUpdatesLabel: UILabel!
  @IBOutlet fileprivate weak var socialNotificationsTitleLabel: UILabel!
  @IBOutlet fileprivate weak var updatesButton: UIButton!
  @IBOutlet fileprivate var emailNotificationButtons: [UIButton]!
  @IBOutlet fileprivate var pushNotificationButtons: [UIButton]!
  @IBOutlet fileprivate var separatorViews: [UIView]!

  internal static func instantiate() -> SettingsNotificationsViewController {
    return Storyboard.SettingsNotifications.instantiate(SettingsNotificationsViewController.self)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.manageProjectNotificationsButton.addTarget(self,
                                                    action: #selector(manageProjectNotificationsTapped),
                                                    for: .touchUpInside)

    self.findFriendsButton.addTarget(self,
                                                    action: #selector(findFriendsTapped),
                                                    for: .touchUpInside)

   self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()
      |> UIViewController.lens.title %~ { _ in Strings.Push_notifications() }

    _ = self.emailNotificationButtons
      ||> settingsNotificationIconButtonStyle
      ||> UIButton.lens.image(for: .normal)
      .~ UIImage(named: "email-icon", in: .framework, compatibleWith: nil)
      ||> UIButton.lens.image(for: .selected)
      .~ image(named: "email-icon", tintColor: .ksr_green_700, inBundle: Bundle.framework)
      ||> UIButton.lens.accessibilityLabel %~ { _ in Strings.Email_notifications() }

    _ = self.findFriendsButton
      |> settingsSectionButtonStyle
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.profile_settings_social_find_friends() }

    _ = self.findFriendsLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_social_find_friends() }

    _ = self.friendActivityLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_social_friend_backs() }

    _ = self.manageProjectNotificationsLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_backer_notifications() }

    _ = self.manageProjectNotificationsButton
      |> settingsSectionButtonStyle
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.profile_settings_backer_notifications() }

    _ = self.newFollowersLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_social_followers() }

    _ = self.projectUpdatesLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_backer_project_updates() }

    _ = self.projectsYouBackTitleLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.Projects_youve_backed() }

    _ = self.pushNotificationButtons
      ||> settingsNotificationIconButtonStyle
      ||> UIButton.lens.image(for: .normal)
      .~ UIImage(named: "mobile-icon", in: .framework, compatibleWith: nil)
      ||> UIButton.lens.image(for: .selected)
      .~ image(named: "mobile-icon", tintColor: .ksr_green_700, inBundle: Bundle.framework)
      ||> UIButton.lens.accessibilityLabel %~ { _ in Strings.Push_notifications() }

    _ = self.separatorViews
      ||> separatorStyle

    _ = self.socialNotificationsTitleLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_social_title() }
  }

  // swiftlint:enable function_body_length

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.goToManageProjectNotifications
      .observeForControllerAction()
      .observeValues { [weak self] _ in self?.goToManageProjectNotifications() }

    self.viewModel.outputs.unableToSaveError
      .observeForControllerAction()
      .observeValues { [weak self] message in
        self?.present(UIAlertController.genericError(message), animated: true, completion: nil)
    }

    self.viewModel.outputs.updateCurrentUser
      .observeForUI()
      .observeValues { user in AppEnvironment.updateCurrentUser(user) }

    self.viewModel.outputs.goToFindFriends
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.goToFindFriends()
    }

    self.followerButton.rac.selected = self.viewModel.outputs.emailNewFollowersSelected
    self.friendActivityButton.rac.selected = self.viewModel.outputs.emailFriendsActivitySelected
    self.manageProjectNotificationsButton.rac.accessibilityHint =
    self.viewModel.outputs.manageProjectNotificationsButtonAccessibilityHint
    self.mobileFollowerButton.rac.selected = self.viewModel.outputs.mobileNewFollowersSelected
    self.mobileFriendActivityButton.rac.selected = self.viewModel.outputs.mobileFriendsActivitySelected
    self.mobileUpdatesButton.rac.selected = self.viewModel.outputs.mobileProjectUpdatesSelected
    self.projectNotificationsCountView.label.rac.text = self.viewModel.outputs.projectNotificationsCount
    self.updatesButton.rac.selected = self.viewModel.outputs.updatesSelected
  }

  @IBAction fileprivate func emailProjectUpdates(_ button: UIButton) {
    self.viewModel.inputs.emailProjectUpdates(selected: !button.isSelected)
  }

  @IBAction fileprivate func mobileUpdatesTapped(_ sender: UIButton) {
    self.viewModel.inputs.mobileProjectUpdatesTapped(selected: !sender.isSelected)
  }

  @IBAction func emailNewFollowersTapped(_ sender: UIButton) {
    self.viewModel.inputs.emailNewFollowersTapped(selected: !sender.isSelected)
  }

  @IBAction func mobileNewFollowersTapped(_ sender: UIButton) {
    self.viewModel.inputs.mobileNewFollowersTapped(selected: !sender.isSelected)
  }

  @IBAction func emailFriendsActivityTapped(_ sender: UIButton) {
    self.viewModel.inputs.emailFriendActivityTapped(selected: !sender.isSelected)
  }

  @IBAction func mobileFriendsActivityTapped(_ sender: UIButton) {
    self.viewModel.inputs.mobileFriendsActivityTapped(selected: !sender.isSelected)
  }

  @objc fileprivate func findFriendsTapped() {
    self.viewModel.inputs.findFriendsTapped()
  }

  @objc fileprivate func manageProjectNotificationsTapped() {
    self.viewModel.inputs.manageProjectNotificationsTapped()
  }

  fileprivate func goToManageProjectNotifications() {
    let vc = SettingsNotificationsViewController.instantiate()
    self.navigationController?.pushViewController(vc, animated: true)
  }

  fileprivate func goToFindFriends() {
    let vc = FindFriendsViewController.configuredWith(source: .settings)
    self.navigationController?.pushViewController(vc, animated: true)
  }
}
