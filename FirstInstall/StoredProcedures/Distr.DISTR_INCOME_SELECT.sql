USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Distr].[DISTR_INCOME_SELECT]
	-- ��������� � ������������� ���� �������, ����� ���� �������� ������������
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	-- 0 - ���, 1 - ������ ���������, 2 - ��� ��������
	@STATUS		TINYINT,
	-- ������ �� ���� ������
	@DEL_BEGIN	SMALLDATETIME,
	@DEL_END	SMALLDATETIME,
	-- �� ������ �����
	@DISTR		INT,
	-- �� �������
	@SYSTEM		UNIQUEIDENTIFIER,
	-- ����
	@NET		UNIQUEIDENTIFIER,
	-- ���
	@TYPE		UNIQUEIDENTIFIER,
	-- 0 - ���, 1 - �����, 2 - ������ ������
	@EXCHANGE	TINYINT,
	-- �������
	@SUBHOST	UNIQUEIDENTIFIER,
	-- ���������� (�� ��?)
	@COMMENT	NVARCHAR(150),
	@RC			INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	
		a.ID, DT_SHORT, CONVERT(VARCHAR(20), NUM) + CASE COMP WHEN 1 THEN '' ELSE '/' + CONVERT(VARCHAR(20), COMP) END AS DIS_STR,
		CONVERT(BIT, CASE 
			WHEN ID_SYSTEM IS NULL OR ID_NET IS NULL THEN 1
			ELSE 0
		END) AS EXCHANGE,
		CASE 
			WHEN ID_SYSTEM IS NULL THEN '� ' + e.SYS_SHORT + ' �� ' + f.SYS_SHORT
			ELSE d.SYS_SHORT
		END AS SYS_STR,
		CASE 
			WHEN ID_NET IS NULL THEN '� ' + h.SHORT + ' �� ' + k.SHORT
			ELSE g.SHORT
		END AS NET_STR,
		REPLICATE('0', 5 - LEN(CONVERT(VARCHAR(20), d.SYS_ORDER))) + CONVERT(VARCHAR(20), d.SYS_ORDER) + ' ' + 
		CONVERT(VARCHAR(20), CONVERT(INT, ROUND(g.COEF * 100, 0))) + ' -- ' +
		d.SYS_SHORT + '/' + g.SHORT AS FREE_SHORT,
		INCOME_DATE, COMMENT, PROCESS_DATE, l.NAME
	FROM 
		Distr.DistrIncome a
		INNER JOIN Distr.DistrTypeActive b ON a.ID_TYPE = b.DT_ID_MASTER
		--INNER JOIN Distr.HostActive c ON c.HST_ID_MASTER = a.ID_HOST
		LEFT OUTER JOIN Distr.SystemActive d ON d.SYS_ID_MASTER = a.ID_SYSTEM
		LEFT OUTER JOIN Distr.SystemActive e ON e.SYS_ID_MASTER = a.ID_OLD_SYS
		LEFT OUTER JOIN Distr.SystemActive f ON f.SYS_ID_MASTER = a.ID_NEW_SYS
		LEFT OUTER JOIN Distr.NetAll g ON g.ID = a.ID_NET
		LEFT OUTER JOIN Distr.NetAll h ON h.ID = a.ID_OLD_NET
		LEFT OUTER JOIN Distr.NetAll k ON k.ID = a.ID_NEW_NET
		LEFT OUTER JOIN Distr.Subhost l ON l.ID = a.ID_SUBHOST
	WHERE (INCOME_DATE >= @BEGIN OR @STATUS = 1 OR @BEGIN IS NULL) 
		AND (INCOME_DATE <= @END OR @STATUS = 1 OR @END IS NULL)
		AND (
				@STATUS IS NULL 
				OR @STATUS = 0 
				OR @STATUS = 1 AND PROCESS_DATE IS NULL AND ID_SYSTEM IS NOT NULL AND ID_NET IS NOT NULL
				OR @STATUS = 2 AND PROCESS_DATE IS NOT NULL
			)
		AND (PROCESS_DATE >= @DEL_BEGIN OR @DEL_BEGIN IS NULL)
		AND (PROCESS_DATE <= @END OR @DEL_END IS NULL)
		AND (NUM = @DISTR OR @DISTR IS NULL)
		AND (ID_SYSTEM = @SYSTEM OR ID_NEW_SYS = @SYSTEM OR @SYSTEM IS NULL)
		AND (ID_NET = @NET OR ID_NEW_NET = @NET OR @NET IS NULL)
		AND (ID_TYPE = @TYPE OR @TYPE IS NULL)
		AND (@EXCHANGE IS NULL OR @EXCHANGE = 0 OR @EXCHANGE = 1 AND ID_SYSTEM IS NOT NULL AND ID_NET IS NOT NULL OR @EXCHANGE = 2 AND (ID_SYSTEM IS NULL OR ID_NET IS NULL))
		AND (ID_SUBHOST = @SUBHOST OR @SUBHOST IS NULL)
		AND (COMMENT LIKE @COMMENT OR @COMMENT IS NULL)
	ORDER BY 
		CASE @STATUS 
			WHEN 1 THEN NULL
			ELSE INCOME_DATE
		END, d.SYS_ORDER, f.SYS_ORDER, g.TECH, g.COEF, k.TECH, k.COEF, NUM, COMP
	
	SELECT @RC = @@ROWCOUNT
END
