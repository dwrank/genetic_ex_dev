pub mod one_max;
pub mod genetic;

use rustler::{Env, LocalPid};

#[rustler::nif(schedule = "DirtyCpu")]
fn run_one_max<'a>(env: Env<'a>, caller: LocalPid, interval: u32) -> one_max::OneMaxStatus {
    return one_max::run(env, caller, interval);
}

#[rustler::nif()]
fn shuffle_vec_u8(genes: Vec<u8>) -> Vec<u8> {
    return genetic::shuffle_vec(genes);
}

#[rustler::nif()]
fn shuffle(chromosome: genetic::Chromosome) -> genetic::Chromosome {
    return genetic::shuffle(chromosome);
}

#[rustler::nif()]
fn crossover_vec_u8(genes1: Vec<u8>, genes2: Vec<u8>) -> (Vec<u8>, Vec<u8>) {
    return genetic::crossover_vec(genes1, genes2);
}

rustler::init!("Elixir.GeneticExDev.GeneticRust",
               [
               run_one_max,
               shuffle_vec_u8,
               shuffle,
               crossover_vec_u8,
               ]);
