from sunpy.net import scraper
from sunpy.time import TimeRange
import urllib
import pandas as pd
import os 
import glob
import tarfile
from dateutil import relativedelta

def read_swpc_reports(file):
    """
    Function to read the daily SWPC files and return X-ray GOES flares that are present.
    
    Parameters
    ----------
    file : `str`
        report txt file (format goes-xrs-report_yyyy.txt)

    Returns
    -------
    flare_list : pandas DataFrame of the event list with associated parameters 
    available from report. It will obviously only be from one day.

    Notes
    -----
    The description of the data format within txt file is here:
    ftp://ftp.swpc.noaa.gov/pub/indices/events/README

    There is more events listed within the SWPC report, this function only parses out the GOES XRS flares
    noted as "XRA"
    """

    with open(file, "r") as f:
        flare_list = []
        for line in f.readlines():
            if "Date:" in line:
                date = line[7:17].replace(" ", "")
            elif "EDITED EVENTS for" in line:
                date = pd.to_datetime(line[18:29]).strftime("%Y%m%d")

            if "XRA" in line:
                event_list = {}
                event_list["date"] = date
                event_list["event_no"] = line[0:4]
                event_list["start_time"] = line[11:15]
                event_list["max_time"] = line[18:22]
                event_list["end_time"] = line[28:32]
                event_list["goes_sat"] = line[34:37]
                event_list["goes_channel"] = line[48:52]
                event_list["goes_class_ind"] = line[58]
                event_list["goes_class"] = line[58:62]
                event_list["integrated_flux"] = line[66:73]
                # to adjust for cases when no active region number
                # and when the NOAA ar numbering passed 9000.
                if len(line)>75:
                    ar = int(line[76:80]) if (line[76:80]!= "    " and '\n' not in line[76:80]) else 0
                    if (ar < 4000 and ar!=0):
                        ar = ar + 10000
                else:
                    ar = 0
                event_list["noaa_ar"] = ar
                flare_list.append(event_list)

    return pd.DataFrame(flare_list)


def get_yearly_tar_files(tstart, tend, savedir='./goes_files'):
    """
    Function to download yearly tar files that contain all the daily swpc reports and
    save them to the `./goes_files` dir (by default).

    Parameters
    ----------
    tstart : ~str
        start date of search to download
    tend : ~str
        end date of search to download
    savedir : ~str, optional
        path to where to save the files. Default is ./goes_files.

    """
    file_url = "ftp://ftp.swpc.noaa.gov/pub//warehouse/%Y/%Y_events.tar.gz"
    goes_scraper = scraper.Scraper(file_url)

    urls = goes_scraper.filelist(TimeRange(tstart, tend))

    for u in urls:
        if os.path.exists(u.split("/")[-1]):
            print("data already downloaded")
        else:
            print("getting data")
            urllib.request.urlretrieve(u, u.split("/")[-1])

    tar_files = glob.glob("*event*.tar.gz")
    for f in tar_files:
        my_tar = tarfile.open(f)
        my_tar.extractall(savedir) # specify which folder to extract to
        my_tar.close()


def get_swpc_reports(tstart, tend, savedir=os.getcwd()+'/goes_files/'):
    """
    Function to search for an download the SWPC event reports.
    The reports are available from 2015-06-29 to present.

    Parameters
    ----------
    tstart : ~str
        start date of search to download
    tend : ~str
        end date of search to download

    savedir : ~str, optional
        directory to download the files to, default is ./goes_files.

    Returns
    -------
    `list` of the files downloaded

    Notes
    -----
    The data is available here as txt files in format `yyyymmddevents.txt`:
    ftp://ftp.swpc.noaa.gov/pub/indices/events/ or ftp://ftp.swpc.noaa.gov/pub//warehouse/%Y/%Y_events.tar.gz

    """


    file_pattern_swpc = ("ftp://ftp.swpc.noaa.gov/pub/indices/events/%Y%m%devents.txt")
    file_scraper_swpc = scraper.Scraper(file_pattern_swpc)

    urls = file_scraper_swpc.filelist(TimeRange(tstart, tend))
    urls.sort()
    for u in urls:
        filepath_dir = savedir + u.split("/")[-1][0:4] + "_events/" 
        filepath = filepath_dir + u.split("/")[-1]
        if not os.path.exists(filepath_dir):
            os.makedirs(filepath_dir)
        if not os.path.exists(filepath):
            print("toi")
            urllib.request.urlretrieve(u, filepath)
        else:
            print("already exists")


def get_swpc_flarelist(tstart, tend, csv_filename='swpc_event_list.csv'):
    """
    Function to read in all SWPC daily reports and save flarelist
    as a csv for flares >=C1.0.

    The flarelist is saved to "swpc_event_list.csv"

    """
    filedir = "./goes_files/%Y_events/%Y%m%devents.txt"
    timerange = TimeRange(tstart, tend)
    t0 = timerange.start.datetime
    files = [t0.strftime(filedir)]
    while timerange.end.datetime>t0:
        t0 = t0 + relativedelta.relativedelta(days=1)
        files.append(t0.strftime(filedir))

    files.sort()

    df_flares = read_swpc_reports(files[0])
    for f in files[1:]:
        try:
            df = read_swpc_reports(f)
            df_flares = pd.concat([df_flares, df])
        except:
            print(f)
    df_flares.reset_index(inplace=True, drop=True)
    df_flares["ts"] = df_flares.date + df_flares.start_time
    df_flares = df_flares.drop_duplicates(subset="ts")

    df_flares_c = df_flares[df_flares["goes_class_ind"].isin(["C", "X", "M"])]
    df_flares_c.reset_index(inplace=True, drop=True)
    df_flares_c.to_csv(csv_filename, index_label=False)



def get_flarelist(tstart, tend):
    get_yearly_tar_files("2010-01-01", "2021-12-31")
    get_swpc_reports(tstart, tend)
    timerange = TimeRange(tstart, tend)

    get_swpc_flarelist(tstart, tend, csv_filename="swpc_flarelist_{:s}-{:s}_concat.csv".format(timerange.start.strftime("%Y%m%d"), timerange.end.strftime("%Y%m%d")))
