﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DistrPriceWeightGet]', 'TF') IS NULL EXEC('CREATE FUNCTION [dbo].[DistrPriceWeightGet] () RETURNS @output TABLE(Id Int) AS BEGIN RETURN END')
GO
ALTER FUNCTION [dbo].[DistrPriceWeightGet]
(
	@HOST	INT,
	@DISTR	INT,
	@COMP	TINYINT,
	@START	SMALLDATETIME,
	@FINISH	SMALLDATETIME
)
RETURNS @TBL TABLE
(
	WEIGHT_OLD DECIMAL(8, 4), WEIGHT_NEW DECIMAL(8, 4), PRICE_OLD MONEY, PRICE_NEW MONEY,
	SYS_OLD	INT, SYS_NEW INT, NET_OLD INT, NET_NEW INT
)
AS
BEGIN
	DECLARE @SYSTEM_OLD	INT
	DECLARE @SYSTEM_NEW	INT
	DECLARE @STATUS_OLD	INT
	DECLARE @STATUS_NEW	INT
	DECLARE @NET_OLD	INT
	DECLARE @NET_NEW	INT
	DECLARE @SST_OLD	DECIMAL(8,4)
	DECLARE @SST_NEW	DECIMAL(8,4)

	SELECT TOP 1 @SYSTEM_OLD = ID_SYSTEM, @NET_OLD = NT_ID_MASTER, @STATUS_OLD = CASE DS_REG WHEN 0 THEN 1 ELSE 0 END, @SST_OLD = SST_SALARY
	FROM
		Reg.RegDistr a
		INNER JOIN Reg.RegHistory b ON a.ID = b.ID_DISTR
		INNER JOIN dbo.DistrStatus c ON b.ID_STATUS = c.DS_ID
		INNER JOIN Din.SystemType d ON d.SST_ID = b.ID_TYPE
		INNER JOIN Din.NetType e ON e.NT_ID = ID_NET
	WHERE ID_HOST = @HOST
		AND DISTR = @DISTR
		AND COMP = @COMP
		AND DATE < @START
	ORDER BY DATE DESC

	SELECT TOP 1 @SYSTEM_NEW = ID_SYSTEM, @NET_NEW = NT_ID_MASTER, @STATUS_NEW = CASE DS_REG WHEN 0 THEN 1 ELSE 0 END, @SST_NEW = SST_SALARY
	FROM
		Reg.RegDistr a
		INNER JOIN Reg.RegHistory b ON a.ID = b.ID_DISTR
		INNER JOIN dbo.DistrStatus c ON b.ID_STATUS = c.DS_ID
		INNER JOIN Din.SystemType d ON d.SST_ID = b.ID_TYPE
		INNER JOIN Din.NetType e ON e.NT_ID = ID_NET
	WHERE ID_HOST = @HOST
		AND DISTR = @DISTR
		AND COMP = @COMP
		AND DATE > @FINISH
	ORDER BY DATE

	IF @SYSTEM_NEW IS NULL AND @NET_NEW IS NULL
		SELECT TOP 1 @SYSTEM_NEW = ID_SYSTEM, @NET_NEW = NT_ID_MASTER, @STATUS_NEW = CASE DS_REG WHEN 0 THEN 1 ELSE 0 END, @SST_NEW = SST_SALARY
		FROM
			Reg.RegDistr a
			INNER JOIN Reg.RegHistory b ON a.ID = b.ID_DISTR
			INNER JOIN dbo.DistrStatus c ON b.ID_STATUS = c.DS_ID
			INNER JOIN Din.SystemType d ON d.SST_ID = b.ID_TYPE
			INNER JOIN Din.NetType e ON e.NT_ID = ID_NET
		WHERE ID_HOST = @HOST
			AND DISTR = @DISTR
			AND COMP = @COMP
			AND DATE > @START
		ORDER BY DATE DESC

	--SELECT @SYSTEM_OLD, @SYSTEM_NEW, @NET_OLD, @NET_NEW, @STATUS_OLD, @STATUS_NEW

	DECLARE @MONTH UNIQUEIDENTIFIER

	SELECT @MONTH = ID
	FROM Common.Period
	WHERE TYPE = 2
		AND @FINISH BETWEEN START AND FINISH

	DECLARE @PRICE_OLD MONEY
	DECLARE @PRICE_NEW MONEY

	SELECT @PRICE_OLD = ROUND(A.[Price] * [Coef], [Round]) * @STATUS_OLD * @SST_OLD
	FROM [Price].[Systems:Price@Get](@FINISH) AS A
	-- ToDo а не надо ли DistrCoef использовать?
	CROSS JOIN [Price].[DistrTypes:Coef@Get](@FINISH) AS B
	WHERE	A.[System_Id] = @SYSTEM_OLD
		AND B.[DistrType_Id] = @NET_OLD;

	SELECT @PRICE_NEW = ROUND(A.[Price] * [Coef], [Round]) * @STATUS_NEW * @SST_NEW
	FROM [Price].[Systems:Price@Get](@FINISH) AS A
	CROSS JOIN [Price].[DistrTypes:Coef@Get](@FINISH) AS B
	WHERE A.[System_Id] = @SYSTEM_NEW
		AND B.[DistrType_Id] = @NET_NEW;

	DECLARE @WEIGHT_OLD DECIMAL(8, 4)
	DECLARE @WEIGHT_NEW DECIMAL(8, 4)

	--ToDo что за хрень с весом? Он в другой таблице!!!
	SELECT @WEIGHT_OLD = a.SystemSalaryWeight * b.WEIGHT * @STATUS_OLD * @SST_OLD
	FROM dbo.SystemTable a
	CROSS JOIN dbo.DistrTypeCoef b
	WHERE SystemID = @SYSTEM_OLD
		--AND ID_PERIOD = @MONTH
		AND ID_MONTH = @MONTH
		AND ID_NET = @NET_OLD;

	SELECT @WEIGHT_NEW = a.SystemSalaryWeight * b.WEIGHT * @STATUS_NEW * @SST_NEW
	FROM dbo.SystemTable a
	CROSS JOIN dbo.DistrTypeCoef b
	WHERE SystemID = @SYSTEM_NEW
		--AND ID_PERIOD = @MONTH
		AND ID_MONTH = @MONTH
		AND ID_NET = @NET_NEW;


	INSERT INTO @TBL(WEIGHT_OLD, WEIGHT_NEW, PRICE_OLD, PRICE_NEW, SYS_OLD, SYS_NEW, NET_OLD, NET_NEW)
		SELECT @WEIGHT_OLD, @WEIGHT_NEW, @PRICE_OLD, @PRICE_NEW, @SYSTEM_OLD, @SYSTEM_NEW, @NET_OLD, @NET_NEW

	RETURN
END
GO
