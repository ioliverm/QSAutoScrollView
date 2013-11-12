QSAutoScrollView
================

QSAtoScrollView is a simple to use content scroll handler for these situations where the keyboard is shown over the 
controls on a UIViewController. It will handle the keyboard appear and disappear notifications and will center
the focused field in the available space. Also, manual scrolling is allowed.

Deployment
----------

Just copy the two provided files (QSAutoScrollView.m and QSAutoScrollView.h) into your project.

How to use it
-------------

If you use Interface Builder, simply drag and drop a UIScrollView below the controls of your view controller, and cange its class by QSAutoScrollView.

If you prefer to instantiate the controls of your viewcontroller programatically, simply add an instance of QSAutoScrollView below the rest of the controls of your viewcontroller.

```ObjectiveC 
// Instantiate and add the auto scroll view
self.autoScrollView = [[QSAutoScrollView alloc] initWithFrame:CGRectZero()];
self.autoScrollView.autoresizengMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
[self.view addSubview : autoScrollView];
	
// Add a control to the scrollview
UITextField *aTextField = [[UITextField alloc] initWithFrame:CGRectMake (10,10,200,34)];
[self.autoScrollView addSubview:aTextField];
```

Then, when you want the focused control to be focused, call:

```ObjectiveC 
[self.autoScrollView textViewActivated:textField];
```

And to recover the content's position, call:

```ObjectiveC 
[self.autoScrollView textViewDeactivated:textField];
```

Note: the parameter passed to textViewActivated and textViewDeactivated is an UIView, so you can use whatever control
you want.

For example, if you're using QSAutoScrollView in a UIViewController with UITextField's, set the UIViewController as
the delegate of the input fields and implement the following (in the view controller):

```ObjectiveC 
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
  [self.scrollView textViewActivated:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  [self.scrollView textViewDeactivated:textField];
}

```

And that's all! The QSAutoScrollView instance will catch the keyboard notifications (show, hide, change frame) and will adjust the scroll in
in order to put the focused field in the middle of the available space.
