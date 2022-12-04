pub mod one_max;

use rustler::{Env, LocalPid};

#[rustler::nif(schedule = "DirtyCpu")]
fn run_one_max<'a>(env: Env<'a>, caller: LocalPid, interval: u32) -> one_max::OneMaxStatus {
    return one_max::run(env, caller, interval);
}

rustler::init!("Elixir.GeneticExDev.GeneticRust",
               [
               run_one_max
               ]);
