ServerEvents.recipes(event => {
	event.remove({ output: 'pamhc2foodcore:fruitpunchitem' })
	event.shapeless(
  Item.of('pamhc2foodcore:fruitpunchitem', 3), // arg 1: output
  [
    'pamhc2foodcore:juiceritem',
    'allthetweaks:atm_star',
    'allthetweaks:atm_star',
    'allthetweaks:atm_star'
  ]
)
})