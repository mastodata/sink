use std::env;

fn main() {
    let ctx = zmq::Context::new();

    let socket = ctx.socket(zmq::PULL).unwrap();
    let sink_address = env::var("SINK_ADDRESS").unwrap();

    println!("Listening on {sink_address:?}");
    socket.bind(&sink_address).unwrap();

    loop {
        println!("{:?}", socket.recv_string(0).unwrap().unwrap());
    }
}
