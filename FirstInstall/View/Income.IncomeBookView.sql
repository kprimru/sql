USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Income].[IncomeBookView]
--WITH SCHEMABINDING
AS
	SELECT
		IB_ID, IB_DATE, IB_ID_MASTER, IB_REPAY,
		CL_ID, CL_ID_MASTER, CL_NAME,
		VD_ID, VD_ID_MASTER, VD_NAME,
		IB_PRICE, CAST(ROUND((IB_PRICE/1.1), 2) AS MONEY) AS IB_PRICE_NDS, IB_SUM, CAST(ROUND((IB_SUM/1.1), 2) AS MONEY) AS IB_SUM_NDS, IB_COUNT, IB_FULL_PAY,
		HLF_ID, HLF_ID_MASTER, HLF_NAME,
		IB_ID_PERSONAL,
		IB_LOCK, IB_NOTE
	FROM
		Income.IncomeBook INNER JOIN
		Common.HalfDetail ON HLF_ID_MASTER = IB_ID_HALF INNER JOIN
		Clients.ClientDetail ON CL_ID_MASTER = IB_ID_CLIENT INNER JOIN
		Clients.VendorDetail ON VD_ID_MASTER = IB_ID_VENDOR
	WHERE HLF_REF IN (1, 3) AND CL_REF IN (1, 3) AND VD_REF IN (1, 3)
		