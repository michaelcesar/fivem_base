export interface GarageItem {
	body: number;
    engine: number;
    fuel: number;
    garage: string;
    hash: string;
    plate: string;
    state: 'out' | 'garaged' | 'impounded' | 'seized' | 'unknown';
    vehicle: string;
    brand: string;
	type: 'car' | 'aircraft' | 'boat' | 'bike';
    // Server: the raw spawn-model name (e.g. 'jugular'), as opposed to `vehicle`, which is the
    // display name ('Jugular'). The server has always sent this - it just was never typed. Used
    // to build the preview-image path. See ADR-075.
    model: string;
}