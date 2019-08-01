import pandas as pd

def prep_interim_data(p_ca_po):
    '''
    helper function to prepare the interim dataset
    intention is to mimic the catalog data at the Employer
    we don't need much of the data, just the unspsc codes and the item names
    '''
    ca_po = pd.read_csv(p_ca_po)
    print("boo")