use rand::Rng;
use std::collections::VecDeque;

use rustler::{Atom, Encoder, Env, NifStruct, NifMap, LocalPid};

#[derive(NifMap)]
//#[module = "GeneticExDev.Native.Genetic.Chromosome"]
pub struct Chromosome {
    genes: Vec<u8>,
    size: usize,
    fitness: usize,
    age: usize,
}

pub fn shuffle_vec<T>(mut genes: Vec<T>) -> Vec<T>
where T: Copy
{
    let mut rng = rand::thread_rng();
    let len = genes.len();
    let half_len = len / 2;

    for _ in 0..half_len {
        let i1 = rng.gen_range(0..half_len);
        let i2 = rng.gen_range(half_len..len);
        let temp = genes[i1];
        genes[i1] = genes[i2];
        genes[i2] = temp;
    }

    genes
}

pub fn shuffle(mut chrom: Chromosome) -> Chromosome
{
    let mut rng = rand::thread_rng();
    let mut genes = chrom.genes;
    let len = genes.len();
    let half_len = len / 2;

    for _ in 0..half_len {
        let i1 = rng.gen_range(0..half_len);
        let i2 = rng.gen_range(half_len..len);
        let temp = genes[i1];
        genes[i1] = genes[i2];
        genes[i2] = temp;
    }

    Chromosome { genes: genes, size: 0, fitness: 0, age: 0 }
}

pub fn crossover_vec<T>(mut genes1: Vec<T>, mut genes2: Vec<T>) -> (Vec<T>, Vec<T>) {
    let glen = genes1.len();

    // split data lists
    let cx_pt = rand::thread_rng().gen_range(0..glen);
    let mut h1 = genes1;
    let mut h2 = genes2;
    let mut t1 = h1.split_off(cx_pt);
    let mut t2 = h2.split_off(cx_pt);

    // crossover
    h1.append(&mut t2);
    h2.append(&mut t1);

    (h1, h2)
}
