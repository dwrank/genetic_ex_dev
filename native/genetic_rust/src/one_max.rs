use rand::Rng;
use std::collections::VecDeque;

use rustler::{Atom, Encoder, Env, NifStruct, LocalPid};

mod atoms {
    rustler::atoms! {
        running,
        done,
    }
}

struct Chromosome {
    sum: u32,
    data: Vec<u8>,
}

#[derive(NifStruct)]
#[module = "GeneticExDev.Native.OneMaxStatus"]
pub struct OneMaxStatus {
    pid: LocalPid,
    state: Atom,
    iters: u32,
    sum: u32,
    solution: Vec<u8>,
}

pub fn run<'a>(env: Env<'a>, caller: LocalPid, interval: u32) -> OneMaxStatus {
    let mut i = 1;
    let pop_size = 100;
    let chrom_size = 1000;
    let mut population = create_population(pop_size, chrom_size);

    loop {
        evaluate(&mut population);

        if population[0].sum == chrom_size as u32 {
            send_update(env, caller, atoms::done(), i, &population);
            break;
        }

        if i % interval == 0 {
            send_update(env, caller, atoms::running(), i, &population);
        }

        let pairs = selection(population);
        population = crossover(pairs);
        mutation(&mut population);
        i += 1;
    }

    return get_status(env, atoms::done(), i, &population);
}

fn send_update<'a>(env: Env<'a>, caller: LocalPid, state: Atom, iters: u32, population: &Vec<Chromosome>) {
    let status = get_status(env, state, iters, &population);
    let term = status.encode(env);
    env.send(&caller, term);
}

fn get_status<'a>(env: Env<'a>, state: Atom, iters: u32, population: &Vec<Chromosome>) -> OneMaxStatus {
    let chr = population.iter().next().unwrap();
    return OneMaxStatus {pid: env.pid(), state: state, iters: iters, sum: chr.sum, solution: chr.data.clone()};
}

fn create_population(pop_size: usize, chrom_size: usize) -> Vec<Chromosome> {
    let mut population: Vec<Chromosome> = Vec::new();

    for _ in 1..=pop_size {
        let mut chromosome = Chromosome {sum: 0, data: Vec::new()};
        for _ in 1..=chrom_size {
            let val = rand::thread_rng().gen_range(0..=1);
            chromosome.data.push(val);
        }
        population.push(chromosome);
    }

    population
}

fn evaluate(population: &mut Vec<Chromosome>) {
    for (_, chromosome) in population.iter_mut().enumerate() {
        chromosome.sum = calc_sum(&chromosome);
    }

    // sort in descending order
    population.sort_by(|a, b| b.sum.cmp(&a.sum));
}

fn selection(mut population: Vec<Chromosome>) -> VecDeque<(Chromosome, Chromosome)> {
    let mut pairs: VecDeque<(Chromosome, Chromosome)> = VecDeque::new();

    while population.len() > 0 {
        let last = population.pop().unwrap();
        pairs.push_front((population.pop().unwrap(), last));
    }

    pairs
}

fn crossover(mut pairs: VecDeque<(Chromosome, Chromosome)>) -> Vec<Chromosome> {
    let mut population: Vec<Chromosome> = Vec::new();
    let dlen = pairs[0].0.data.len();

    while pairs.len() > 0 {
        let (mut chr1, mut chr2) = pairs.pop_front().unwrap();

        // split data lists
        let cx_pt = rand::thread_rng().gen_range(0..dlen);
        let h1 = &mut chr1.data;
        let h2 = &mut chr2.data;
        let mut t1 = h1.split_off(cx_pt);
        let mut t2 = h2.split_off(cx_pt);

        // crossover
        h1.append(&mut t2);
        h2.append(&mut t1);

        population.push(chr1);
        population.push(chr2);
    }

    population
}

fn mutation(population: &mut Vec<Chromosome>) {
    let mut rng = rand::thread_rng();
    for (_, chromosome) in population.iter_mut().enumerate() {
        if rng.gen::<f64>() < 0.05 {
            shuffle(chromosome);
        }
    }
}

fn shuffle(chromosome: &mut Chromosome) {
    let mut rng = rand::thread_rng();
    let data = &mut chromosome.data;
    let len = data.len();
    let half_len = len / 2;

    for _ in 0..half_len {
        let i1 = rng.gen_range(0..half_len);
        let i2 = rng.gen_range(half_len..len);
        let temp = data[i1];
        data[i1] = data[i2];
        data[i2] = temp;
    }
}

fn calc_sum(chromosome: &Chromosome) -> u32 {
    let mut sum: u32 = 0;
    for val in chromosome.data.iter() {
        sum += *val as u32;
    }
    sum
}
