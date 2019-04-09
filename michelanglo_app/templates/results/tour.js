/*
window.tour_result = new Tour({
          backdrop: true,
          orphan: true,
          onStart: function () {$('#nav-protein-tab').trigger('click');},
          steps: [
          {
            element: "#nav-protein-tab",
            title: "Example of interactive",
            content: `${info.attr.protein|n}`,
            placement: "top",
              onNext: function() {$('#nav-code-tab').trigger('click');}
          },{
            element: "#nav-code-tab",
            title: "Code to use",
            content: `${info.attr.code|n}`,
            placement: "top",
              onNext: function() {$('#nav-implement-tab').trigger('click');}
          },{
            element: "#nav-implement-tab",
            title: "Code to use",
            content: `${info.attr.implement|n}`,
            placement: "top",
              onNext: function() {$('#nav-downloads-tab').trigger('click');}
          },{
            element: "#nav-downloads-tab",
            title: "Code to use",
            content: `${info.attr.downloads|n}`,
            placement: "top",
              onNext: function() {$('#nav-downloads-tab').trigger('click');}
          }]});

        $('#tour_result').click(function () {
            // Initialize the tour
            // Start the tour
            if (tour_result.ended()) {tour_result.goTo(0);}
            tour_result.start(true);
        });
        */
