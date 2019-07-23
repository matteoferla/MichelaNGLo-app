## Reported bugs

* On the home page, the transition is too fast – I can't read anything. **RES**  &mdash; changed from 5 s to 8 s. `window.frequency = 8000` in console changes it.
* On the home page, some of the text hangs out of the boxes **RES** &mdash;this is a bug... boxes have a fixed height that is independent of vw or em.
**MPF**
* Download a totally offline version of page **BDM**
* Messages of progress are crap. The problem is that the log is committed (stringified actually) when the respose is give. Switching to a unique log is a better option. **MPF**
* Mobile: what to do? **MPF**

## Fixed
* I can't close the display controls once I've opened them **RES**
* 'author' (wrong) vs. 'authors' field in Page. **MPF**