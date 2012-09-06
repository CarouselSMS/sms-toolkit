$.fn.submit_with_timer = function(sec) {
  var seconds = sec || 3;
  return this.each(function() {
    var btn = $(this), classes = btn[0].className;

    var handler = function(e) {
      e.preventDefault();

      var interval;
      var time = seconds;
      var timer_text = function() { return "Stop it! (" + time + " sec)"; };

      var cancel_btn = $("<button/>").addClass(classes).addClass('danger').text(timer_text());
      var revert = function() {
        clearInterval(interval);
        cancel_btn.replaceWith(btn);
      };

      cancel_btn.click(function() {
        revert();
        btn.click(handler);
      });

      btn.replaceWith(cancel_btn);

      var nextAction = function() {
        time--;
        if (time == 0) {
          revert();
          btn.click();
          btn[0].disabled = true;
        } else {
          cancel_btn.text(timer_text());
        }
      };

      interval = setInterval(nextAction, 1000);
    };

    btn.click(handler);
  });
};