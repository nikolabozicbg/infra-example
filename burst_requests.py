#!/usr/bin/env python

from logging import exception
import requests
import aiohttp
import asyncio
import time
from datetime import datetime

MAXREQ = 50
MAXTHREAD = 1
g_thread_limit = asyncio.Semaphore(MAXTHREAD)

start_time = time.time()
lcount = 0
tarr = []
bytes_arr = []
log_arr = []

#
# For Tunneling to a AWS instance:
#       ssh -i ~/.ssh/aws_cluster_key -L 8080:10.14.150.22:80 -N ec2-user@54.246.153.61
#    then localhost:8080 becomes a tunnel to EHI instance
#
# This teat writes into syllo_cs_transaction Postgres DB Table.
# Find those records with:
# SELECT * FROM public.syllo_cs_transaction where (merchant_name = 'Pannovate Test' and vendor_reference like '%PAN-%') order by created_at desc;
# Delete:
# PSQL: DELETE from syllo_cs_transaction sct where merchant_name like '%Pannovate Test%';
# Mongo: db.getCollection('syllo_gps_ehi_messages').deleteMany({'content.txnDesc': 'Pannovate Test'})
#
# It also writes to a MOngoDB DB table, and it can be found by simmilar query.
#
# CAUTION:
# <Token>154510682</Token> - Has to remain the same
# <TXn_ID>PAN-{GENERATE_TIMESTAMP_HERE}</TXn_ID>
#

# URL = 'https://api.tnbank.pannovate.net/webhooks/gps/ehi'
URL = 'http://127.0.0.1:8080/webhooks/gps/ehi'

DATA = '''<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
  <s:Body>
    <GetTransaction xmlns="http://tempuri.org/">
      <Acquirer_id_DE32>06400748</Acquirer_id_DE32>
      <ActBal>0.00</ActBal>
      <Additional_Amt_DE54 />
      <Amt_Tran_Fee_DE28 />
      <Auth_Code_DE38>187836</Auth_Code_DE38>
      <Avl_Bal>0.00</Avl_Bal>
      <Bill_Amt>-2.00</Bill_Amt>
      <Bill_Ccy>826</Bill_Ccy>
      <BlkAmt>0.00</BlkAmt>
      <Cust_Ref />
      <FX_Pad>0.00</FX_Pad>
      <Fee_Fixed>0.00</Fee_Fixed>
      <Fee_Rate>0.00</Fee_Rate>
      <LoadSRC />
      <LoadType />
      <MCC_Code>5999</MCC_Code>
      <MCC_Desc>Miscellaneous Specialty Retail</MCC_Desc>
      <MCC_Pad>0.00</MCC_Pad>
      <Merch_ID_DE42>DE0100000087074</Merch_ID_DE42>
      <Merch_Name_DE43>Pannovate Test</Merch_Name_DE43>
      <Note />
      <POS_Data_DE22>0710</POS_Data_DE22>
      <POS_Data_DE61 />
      <POS_Termnl_DE41>37F73539</POS_Termnl_DE41>
      <POS_Time_DE12>152458</POS_Time_DE12>
      <Proc_Code>000000</Proc_Code>
      <Resp_Code_DE39>00</Resp_Code_DE39>
      <Ret_Ref_No_DE37>202716366258</Ret_Ref_No_DE37>
      <Settle_Amt>2.00</Settle_Amt>
      <Settle_Ccy>826</Settle_Ccy>
      <Status_Code>00</Status_Code>
      <Token>154510682</Token>
      <Trans_link>220127366258400748</Trans_link>
      <Txn_Amt>2.0000</Txn_Amt>
      <Txn_CCy>826</Txn_CCy>
      <Txn_Ctry>GBR</Txn_Ctry>
      <Txn_Desc>Pannovate Test</Txn_Desc>
      <Txn_GPS_Date>2022-01-27 15:25:01.510</Txn_GPS_Date>
      <TXn_ID>PAN-%s</TXn_ID>
      <Txn_Stat_Code>A</Txn_Stat_Code>
      <TXN_Time_DE07>0127162501</TXN_Time_DE07>
      <Txn_Type>A</Txn_Type>
      <Additional_Data_DE48 />
      <Authorised_by_GPS>N</Authorised_by_GPS>
      <AVS_Result />
      <CU_Group>TNB-CU-001</CU_Group>
      <InstCode>TNB</InstCode>
      <MTID>0100</MTID>
      <ProductID>9651</ProductID>
      <Record_Data_DE120 />
      <SubBIN>42189401</SubBIN>
      <TLogIDOrg>0</TLogIDOrg>
      <VL_Group>TNB-VL-001</VL_Group>
      <Dom_Fee_Fixed>0.00</Dom_Fee_Fixed>
      <Non_Dom_Fee_Fixed>0.00</Non_Dom_Fee_Fixed>
      <Fx_Fee_Fixed>0.00</Fx_Fee_Fixed>
      <Other_Fee_Amt>0.00</Other_Fee_Amt>
      <Fx_Fee_Rate>0.00</Fx_Fee_Rate>
      <Dom_Fee_Rate>0.00</Dom_Fee_Rate>
      <Non_Dom_Fee_Rate>0.00</Non_Dom_Fee_Rate>
      <Additional_Data_DE124 />
      <CVV2 />
      <Expiry_Date />
      <PAN_Sequence_Number />
      <PIN>0</PIN>
      <PIN_Enc_Algorithm />
      <PIN_Format />
      <PIN_Key_Index />
      <SendingAttemptCount>0</SendingAttemptCount>
      <source_bank_ctry />
      <source_bank_account_format />
      <source_bank_account />
      <dest_bank_ctry />
      <dest_bank_account_format />
      <dest_bank_account />
      <GPS_POS_Capability>00001001000000000000000100010010000000000001130C9</GPS_POS_Capability>
      <GPS_POS_Data>0170000000000Nx00200102C0N</GPS_POS_Data>
      <Acquirer_Reference_Data_031 />
      <Response_Source />
      <Response_Source_Why>0</Response_Source_Why>
      <Message_Source />
      <Message_Why>0</Message_Why>
      <traceid_lifecycle>VIS1-20220127-482027555018107</traceid_lifecycle>
      <Balance_Sequence>0</Balance_Sequence>
      <Balance_Sequence_Exthost>0</Balance_Sequence_Exthost>
      <PaymentToken_id />
      <PaymentToken_creator />
      <PaymentToken_expdate />
      <PaymentToken_type />
      <PaymentToken_status />
      <PaymentToken_creatorStatus></PaymentToken_creatorStatus>
      <PaymentToken_wallet />
      <PaymentToken_deviceType />
      <PaymentToken_lang></PaymentToken_lang>
      <PaymentToken_deviceTelNum />
      <PaymentToken_deviceIp />
      <PaymentToken_deviceId />
      <PaymentToken_deviceName />
      <PaymentToken_activationCode />
      <PaymentToken_activationExpiry />
      <PaymentToken_activationMethodData />
      <PaymentToken_activationMethod />
      <ICC_System_Related_Data_DE55>9F34031F00029F6E04207000009F33036068C8950500000000009F3704330D4EA89F100706011203A000009F260853E936ADA06446CA9F3602004E820200209C01009F1A0208269A032201279F02060000000002005F2A0208268407A0000000031010</ICC_System_Related_Data_DE55>
      <Merch_Name>Pannovate Test</Merch_Name>
      <Merch_Street />
      <Merch_City>Gibraltar</Merch_City>
      <Merch_Region />
      <Merch_Postcode />
      <Merch_Country>GBR</Merch_Country>
      <Merch_Tel />
      <Merch_URL />
      <Merch_Name_Other />
      <Merch_Net_id />
      <Merch_Tax_id />
      <Merch_Contact />
      <auth_type>0</auth_type>
      <auth_expdate_utc>2022-02-04 15:25:01.457       </auth_expdate_utc>
      <Matching_Txn_ID />
      <Reason_ID />
      <Dispute_Condition />
      <Network_Chargeback_Reference_Id />
      <Acquirer_Forwarder_ID />
      <Currency_Code_Fee />
      <Currency_Code_Fee_Settlement />
      <Interchange_Amount_Fee />
      <Interchange_Amount_Fee_Settlement />
      <Clearing_Process_Date />
      <Settlement_Date />
      <DCC_Indicator></DCC_Indicator>
      <multi_part_txn />
      <multi_part_txn_final />
      <multi_part_number />
      <multi_part_count />
      <SettlementIndicator />
      <Network_TxnAmt_To_BillAmt_Rate>1000000:6</Network_TxnAmt_To_BillAmt_Rate>
      <Network_TxnAmt_To_BaseAmt_Rate />
      <Network_BaseAmt_To_BillAmt_Rate />
      <POS_Date_DE13>2022-01-27</POS_Date_DE13>
      <Traceid_Message>VIS1-20220127-482027555018107</Traceid_Message>
      <Traceid_Original />
      <Network_Currency_Conversion_Date />
      <Mastercard_AdviceReasonCode_DE60 />
      <Network_Original_Data_Elements_DE90 />
      <Visa_ResponseInfo_DE44>    2</Visa_ResponseInfo_DE44>
      <Visa_STIP_Reason_Code />
      <Network_Issuer_Settle_ID />
      <Network_Replacement_Amounts_DE95 />
      <Visa_POS_Data_DE60>95000010</Visa_POS_Data_DE60>
      <Network_Transaction_ID>0482027555018107</Network_Transaction_ID>
      <Misc_TLV_Data />
    </GetTransaction>
  </s:Body>
</s:Envelope>'''
HEADERS = {"Content-Type": "application/xml"}
TIMEOUT =aiohttp.ClientTimeout(total=120, connect=60)

async def worker(session):
	global lcount
	ts = time.time()
	async with session.post(URL,
													data=DATA % time.time(),
													headers=HEADERS) as response:
		lcount +=1
		res = await response.text() #.read()
		tarr.append(time.time() - ts)
		bytes_arr.append(str(res) + '\n')
		print("[{Cnt:3}] {Ts} - {Cod} - {Tm} s".format(Cnt=lcount, Ts=ts, Cod=response.status, Tm="{0:.6f}".format(round(time.time() - ts, 6))))
		log_arr.append("[{Cnt:3}] {Ts} - {Cod} - {Tm} s\n".format(Cnt=lcount, Ts=ts, Cod=response.status, Tm="{0:.6f}".format(round(time.time() - ts, 6))))


async def run(worker, *argv):
	async with g_thread_limit:
		await worker(*argv)


async def main():
	try:
		async with aiohttp.ClientSession(timeout=TIMEOUT) as session:
			await asyncio.gather(*[run(worker, session) for _ in range(MAXREQ)])
	except aiohttp.ClientError as aioe:
		print('Client Exception!!!', aioe)
	except asyncio.TimeoutError as asye:
		print('Timeout Exception!!!', asye)


if __name__ == '__main__':
	# Don't use asyncio.run() - it produces a lot of errors on exit.
	# asyncio.get_event_loop().run_until_complete(main())
	log_arr.append(URL + '\n')
	bytes_arr.append(URL + '\n')
	asyncio.run(main())

with open("burst_req_output_{}.log".format(start_time), "w") as lf:
	lf.writelines(log_arr)

with open("burst_req_output_{}.log".format(start_time), "a") as lf:
	print("--- TOTAL TIME FOR REQUESTS: %s seconds ---" % (time.time() - start_time))
	lf.write("--- TOTAL TIME FOR REQUESTS: %s seconds ---\n" % (time.time() - start_time))

	tavg = 0
	for t in tarr:
		tavg += t
	print("--- AVERAGE TIME FOR REQUEST: {0:.6f} seconds ---".format(round((tavg/len(tarr)),6)))
	lf.write("--- AVERAGE TIME FOR REQUEST: {0:.6f} seconds ---\n".format(round((tavg/len(tarr)),6)))

	tmin = tarr[0]
	for t in tarr:
		if t < tmin:
			tmin = t
	print("--- MIN TIME FOR REQUEST: {0:.6f} seconds ---".format(round((tmin),6)))
	lf.write("--- MIN TIME FOR REQUEST: {0:.6f} seconds ---\n".format(round((tmin),6)))

	tmax = tarr[0]
	for t in tarr:
		if t > tmax:
			tmax = t
	print("--- MAX TIME FOR REQUEST: {0:.6f} seconds ---".format(round(tmax,6)))
	lf.write("--- MAX TIME FOR REQUEST: {0:.6f} seconds ---\n".format(round(tmax,6)))

	imax = tarr.index(tmax)
	print("--- TIMESTAMP FOR LONGEST REQUEST: {} ---".format(log_arr[imax+1].split('-')[0].split(']')[1].strip()))
	lf.write("--- TIMESTAMP FOR LONGEST REQUEST: {} ---\n".format(log_arr[imax+1].split('-')[0].split(']')[1].strip()))

	# Convert timestamp to date: print(datetime.fromtimestamp(1643399639.8847172))
	print("--- DATETIME FOR LONGEST REQUEST: {} ---".format(datetime.fromtimestamp(log_arr[imax+1].split('-')[0].split(']')[1].strip())))
	lf.write("--- DATETIME FOR LONGEST REQUEST: {} ---\n".format(datetime.fromtimestamp(log_arr[imax+1].split('-')[0].split(']')[1].strip())))

	print("--- TOTAL TEST TIME: %s seconds ---" % (time.time() - start_time))
	lf.write("--- TOTAL TEST TIME: %s seconds ---\n" % (time.time() - start_time))

with open("burst_req_responses_{}.log".format(start_time), "w") as rf:
	rf.writelines(bytes_arr)

"""
CURL command with the above payload:
curl --location --request POST 'https://api.tnbank.pannovate.net/webhooks/gps/ehi' \
--header 'Content-Type: application/xml' \
--data-raw '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
  <s:Body>
    <GetTransaction xmlns="http://tempuri.org/">
      <Acquirer_id_DE32>06400748</Acquirer_id_DE32>
      --- CUT OUT HERE FOR SPACE ---
      <Misc_TLV_Data />
    </GetTransaction>
  </s:Body>
</s:Envelope>'
"""
