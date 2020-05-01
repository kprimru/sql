USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SUBHOST_EXPORT_DATA]
	@SH		NVARCHAR(32),
	@TYPE	NVARCHAR(32),
	@ENC	BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @SUBHOST UNIQUEIDENTIFIER

		DECLARE @SH_REG_ADD VARCHAR(20)
		DECLARE @SH_REG VARCHAR(20)

		SELECT @SUBHOST = SH_ID, @SH_REG = SH_REG, @SH_REG_ADD = SH_REG_ADD
		FROM dbo.Subhost
		WHERE SH_REG = @SH

		SET @SH_REG = '(' + @SH_REG + ')%'
		SET @SH_REG_ADD = '(' + @SH_REG_ADD + ')%'

		DECLARE @DATA	NVARCHAR(MAX)

		IF @TYPE = N'SIZE'
			SET @DATA =
				(
					SELECT InfoBankName AS '@INAME', IBF_NAME AS '@FNAME', CONVERT(VARCHAR(20), IBS_DATE, 112) AS '@IDATE', CONVERT(VARCHAR(20), IBS_SIZE) AS '@ISIZE'
					FROM
						(
							SELECT DISTINCT InfoBankName, IBF_NAME, IBS_DATE, IBS_SIZE
							FROM
								dbo.InfoBankSize a
								INNER JOIN dbo.InfoBankFile b ON a.IBS_ID_FILE = b.IBF_ID
								INNER JOIN dbo.InfoBankTable c ON c.InfoBankID = b.IBF_ID_IB
							WHERE IBS_DATE >= dbo.DateOf(DATEADD(MONTH, -1, GETDATE()))
							/*ORDER BY SystemOrder, InfoBankOrder, IBF_NAME, IBS_DATE*/
						) AS a
					FOR XML PATH('item'), ROOT('size')
				)
		ELSE IF @TYPE = 'DOCS'
			SET @DATA =
				(
					SELECT SystemBaseName AS '@SNAME', InfoBankName AS '@INAME', CONVERT(VARCHAR(20), StatisticDate, 112) AS '@IDATE', CONVERT(VARCHAR(20), Docs) AS '@IDOCS'
					FROM
						(
							SELECT DISTINCT StatisticDate, SystemBaseName, InfoBankName, Docs
							FROM
								dbo.StatisticTable a
								INNER JOIN dbo.SystemBanksView b WITH(NOEXPAND) ON a.InfoBankID = b.InfoBankID
							WHERE StatisticDate >= dbo.DateOf(DATEADD(MONTH, -1, GETDATE()))
						) AS a
					FOR XML PATH('item'), ROOT('docs')
				)
		ELSE IF @TYPE = 'REG'
			SET @DATA =
				(
					SELECT
						SystemName AS '@SYS', DistrNumber AS '@DISTR', CompNumber AS '@COMP', DistrType AS '@TYPE', TechnolType AS '@TECH',
						NetCount AS '@NET', SubHost AS '@SUBHOST', TransferCount AS '@TCNT', TransferLeft AS '@TLEFT', Service AS '@SERVICE',
						RegisterDate AS '@DATE', Comment AS '@COMMENT', Complect AS '@COMPLECT', ODON AS '@ODON', ODOFF AS 'ODOFF'
					FROM
						(
							SELECT SystemName, DistrNumber, CompNumber, DistrType, TechnolType, NetCount, SubHost, TransferCount, TransferLeft, Service, RegisterDate, Comment, Complect, ODON, ODOFF
							FROM
								dbo.RegNodeTable
							WHERE Comment LIKE @SH_REG OR Comment LIKE @SH_REG_ADD

							UNION

							SELECT a.SystemName, DistrNumber, CompNumber, DistrType, TechnolType, NetCount, SubHost, TransferCount, TransferLeft, Service, RegisterDate, Comment, Complect, ODON, ODOFF
							FROM
								dbo.RegNodeTable a
								INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
								INNER JOIN dbo.SubhostComplect c ON SC_DISTR = DistrNumber AND SC_COMP = CompNumber AND c.SC_ID_HOST = b.HostID
							WHERE SystemReg = 1 AND SC_REG = 1 AND SC_ID_SUBHOST = @SUBHOST

							UNION

							SELECT SystemName, DistrNumber, CompNumber, DistrType, TechnolType, NetCount, SubHost, TransferCount, TransferLeft, Service, RegisterDate, Comment, Complect, ODON, ODOFF
							FROM dbo.RegNodeTable a
							WHERE Complect IN
								(
									SELECT Complect
									FROM
										dbo.RegNodeTable a
										INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
										INNER JOIN dbo.SubhostComplect c ON SC_DISTR = DistrNumber AND SC_COMP = CompNumber AND c.SC_ID_HOST = b.HostID
									WHERE SystemReg = 1 AND SC_REG = 1 AND SC_ID_SUBHOST = @SUBHOST
								)
						) AS o_O
					FOR XML PATH('item'), ROOT('reg')
				)
		ELSE IF @TYPE = 'PROT_TEXT'
			SET @DATA =
				(
					SELECT HostReg AS '@HOST', DISTR AS '@DISTR', COMP AS '@COMP', CONVERT(VARCHAR(20), DATE, 112) AS '@DATE', CNT AS '@CNT', COMMENT AS '@COMMENT'
					FROM
						Reg.ProtocolText AS a
						INNER JOIN
							(
								SELECT HostID, DistrNumber, CompNumber
								FROM
									dbo.RegNodeTable a
									INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
								WHERE (Comment LIKE @SH_REG OR Comment LIKE @SH_REG_ADD) AND SystemReg = 1

								UNION

								SELECT b.HostID, DistrNumber, CompNumber
								FROM
									dbo.RegNodeTable a
									INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
									INNER JOIN dbo.SubhostComplect c ON SC_DISTR = DistrNumber AND SC_COMP = CompNumber AND c.SC_ID_HOST = b.HostID
								WHERE SystemReg = 1 AND SC_REG = 1 AND SC_ID_SUBHOST = @SUBHOST

								UNION

								SELECT HostID, DistrNumber, CompNumber
								FROM
									dbo.RegNodeTable a
									INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
								WHERE Complect IN
									(
										SELECT Complect
										FROM
											dbo.RegNodeTable a
											INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
											INNER JOIN dbo.SubhostComplect c ON SC_DISTR = DistrNumber AND SC_COMP = CompNumber AND c.SC_ID_HOST = b.HostID
										WHERE SystemReg = 1 AND SC_REG = 1 AND SC_ID_SUBHOST = @SUBHOST
									)
							) AS b ON a.ID_HOST = HostID AND a.DISTR = b.DistrNumber AND a.COMP = b.CompNumber
						INNER JOIN dbo.Hosts c ON a.ID_HOST = c.HostID
					WHERE DATE >= dbo.DateOf(DATEADD(MONTH, -1, GETDATE()))
					FOR XML PATH('item'), ROOT('prot_text')
				)
		ELSE IF @TYPE = 'PROT'
			SET @DATA =
				(
					SELECT
						HostReg AS '@HOST', RPR_DISTR AS '@DISTR', RPR_COMP AS '@COMP', CONVERT(VARCHAR(20), RPR_DATE, 120) AS '@DATE',
						RPR_OPER AS '@OPER', RPR_REG AS '@REG', RPR_TYPE AS '@TYPE', RPR_TEXT AS '@TEXT', RPR_USER AS '@USER', RPR_COMPUTER AS '@COMPUTER'
					FROM
						dbo.RegProtocol AS a
						INNER JOIN
							(
								SELECT HostID, DistrNumber, CompNumber
								FROM
									dbo.RegNodeTable a
									INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
								WHERE (Comment LIKE @SH_REG OR Comment LIKE @SH_REG_ADD) AND SystemReg = 1

								UNION

								SELECT b.HostID, DistrNumber, CompNumber
								FROM
									dbo.RegNodeTable a
									INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
									INNER JOIN dbo.SubhostComplect c ON SC_DISTR = DistrNumber AND SC_COMP = CompNumber AND c.SC_ID_HOST = b.HostID
								WHERE SystemReg = 1 AND SC_REG = 1 AND SC_ID_SUBHOST = @SUBHOST

								UNION

								SELECT HostID, DistrNumber, CompNumber
								FROM
									dbo.RegNodeTable a
									INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
								WHERE Complect IN
									(
										SELECT Complect
										FROM
											dbo.RegNodeTable a
											INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
											INNER JOIN dbo.SubhostComplect c ON SC_DISTR = DistrNumber AND SC_COMP = CompNumber AND c.SC_ID_HOST = b.HostID
										WHERE SystemReg = 1 AND SC_REG = 1 AND SC_ID_SUBHOST = @SUBHOST
									)
							) AS b ON a.RPR_ID_HOST = HostID AND a.RPR_DISTR = b.DistrNumber AND a.RPR_COMP = b.CompNumber
						INNER JOIN dbo.Hosts c ON a.RPR_ID_HOST = c.HostID
					WHERE RPR_DATE >= dbo.DateOf(DATEADD(MONTH, -1, GETDATE()))
					FOR XML PATH('item'), ROOT('prot')
				)
		ELSE IF @TYPE = 'ALL'
		BEGIN
			SET @DATA = ISNULL(
				(
					SELECT SystemBaseName AS '@SNAME', InfoBankName AS '@INAME', CONVERT(VARCHAR(20), StatisticDate, 112) AS '@IDATE', CONVERT(VARCHAR(20), Docs) AS '@IDOCS'
					FROM
						(
							SELECT DISTINCT StatisticDate, SystemBaseName, InfoBankName, Docs
							FROM
								dbo.StatisticTable a
								INNER JOIN dbo.SystemBanksView b WITH(NOEXPAND) ON a.InfoBankID = b.InfoBankID
							WHERE StatisticDate >= dbo.DateOf(DATEADD(MONTH, -1, GETDATE()))
						) AS a
					FOR XML PATH('item'), ROOT('docs')
				)	, '')


			SET @DATA = @DATA + ISNULL(
				(
					SELECT
						SystemName AS '@SYS', DistrNumber AS '@DISTR', CompNumber AS '@COMP', DistrType AS '@TYPE', TechnolType AS '@TECH',
						NetCount AS '@NET', SubHost AS '@SUBHOST', TransferCount AS '@TCNT', TransferLeft AS '@TLEFT', Service AS '@SERVICE',
						RegisterDate AS '@DATE', Comment AS '@COMMENT', Complect AS '@COMPLECT', ODon AS '@ODON', ODoff AS '@ODOFF'
					FROM
						(
							SELECT
								SystemName, DistrNumber, CompNumber, DistrType, TechnolType, NetCount, SubHost,
								TransferCount, TransferLeft, Service, RegisterDate, Comment, Complect, ODon, ODoff
							FROM
								dbo.RegNodeTable
							WHERE Comment LIKE @SH_REG OR Comment LIKE @SH_REG_ADD

							UNION

							SELECT
								a.SystemName, DistrNumber, CompNumber, DistrType, TechnolType, NetCount, SubHost,
								TransferCount, TransferLeft, Service, RegisterDate, Comment, Complect, ODon, ODoff
							FROM
								dbo.RegNodeTable a
								INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
								INNER JOIN dbo.SubhostComplect c ON SC_DISTR = DistrNumber AND SC_COMP = CompNumber AND c.SC_ID_HOST = b.HostID
							WHERE SystemReg = 1 AND SC_REG = 1 AND SC_ID_SUBHOST = @SUBHOST

							UNION

							SELECT
								SystemName, DistrNumber, CompNumber, DistrType, TechnolType, NetCount, SubHost,
								TransferCount, TransferLeft, Service, RegisterDate, Comment, Complect, ODon, ODoff
							FROM dbo.RegNodeTable a
							WHERE Complect IN
								(
									SELECT Complect
									FROM
										dbo.RegNodeTable a
										INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
										INNER JOIN dbo.SubhostComplect c ON SC_DISTR = DistrNumber AND SC_COMP = CompNumber AND c.SC_ID_HOST = b.HostID
									WHERE SystemReg = 1 AND SC_REG = 1 AND SC_ID_SUBHOST = @SUBHOST
								)
						) AS o_O
					FOR XML PATH('item'), ROOT('reg')
				), '')

			SET @DATA = @DATA + ISNULL(
				(
					SELECT HostReg AS '@HOST', DISTR AS '@DISTR', COMP AS '@COMP', CONVERT(VARCHAR(20), DATE, 112) AS '@DATE', CNT AS '@CNT', COMMENT AS '@COMMENT'
					FROM
						Reg.ProtocolText AS a
						INNER JOIN
							(
								SELECT HostID, DistrNumber, CompNumber
								FROM
									dbo.RegNodeTable a
									INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
								WHERE (Comment LIKE @SH_REG OR Comment LIKE @SH_REG_ADD) AND SystemReg = 1

								UNION

								SELECT b.HostID, DistrNumber, CompNumber
								FROM
									dbo.RegNodeTable a
									INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
									INNER JOIN dbo.SubhostComplect c ON SC_DISTR = DistrNumber AND SC_COMP = CompNumber AND c.SC_ID_HOST = b.HostID
								WHERE SystemReg = 1 AND SC_REG = 1 AND SC_ID_SUBHOST = @SUBHOST

								UNION

								SELECT HostID, DistrNumber, CompNumber
								FROM
									dbo.RegNodeTable a
									INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
								WHERE Complect IN
									(
										SELECT Complect
										FROM
											dbo.RegNodeTable a
											INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
											INNER JOIN dbo.SubhostComplect c ON SC_DISTR = DistrNumber AND SC_COMP = CompNumber AND c.SC_ID_HOST = b.HostID
										WHERE SystemReg = 1 AND SC_REG = 1 AND SC_ID_SUBHOST = @SUBHOST
									)
							) AS b ON a.ID_HOST = HostID AND a.DISTR = b.DistrNumber AND a.COMP = b.CompNumber
						INNER JOIN dbo.Hosts c ON a.ID_HOST = c.HostID
					WHERE DATE >= dbo.DateOf(DATEADD(MONTH, -1, GETDATE()))
					FOR XML PATH('item'), ROOT('prot_text')
				), '')


			SET @DATA = @DATA + ISNULL(
				(
					SELECT
						HostReg AS '@HOST', RPR_DISTR AS '@DISTR', RPR_COMP AS '@COMP', CONVERT(VARCHAR(20), RPR_DATE, 120) AS '@DATE',
						RPR_OPER AS '@OPER', RPR_REG AS '@REG', RPR_TYPE AS '@TYPE', RPR_TEXT AS '@TEXT', RPR_USER AS '@USER', RPR_COMPUTER AS '@COMPUTER'
					FROM
						dbo.RegProtocol AS a
						INNER JOIN
							(
								SELECT HostID, DistrNumber, CompNumber
								FROM
									dbo.RegNodeTable a
									INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
								WHERE (Comment LIKE @SH_REG OR Comment LIKE @SH_REG_ADD) AND SystemReg = 1

								UNION

								SELECT b.HostID, DistrNumber, CompNumber
								FROM
									dbo.RegNodeTable a
									INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
									INNER JOIN dbo.SubhostComplect c ON SC_DISTR = DistrNumber AND SC_COMP = CompNumber AND c.SC_ID_HOST = b.HostID
								WHERE SystemReg = 1 AND SC_REG = 1 AND SC_ID_SUBHOST = @SUBHOST

								UNION

								SELECT HostID, DistrNumber, CompNumber
								FROM
									dbo.RegNodeTable a
									INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
								WHERE Complect IN
									(
										SELECT Complect
										FROM
											dbo.RegNodeTable a
											INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
											INNER JOIN dbo.SubhostComplect c ON SC_DISTR = DistrNumber AND SC_COMP = CompNumber AND c.SC_ID_HOST = b.HostID
										WHERE SystemReg = 1 AND SC_REG = 1 AND SC_ID_SUBHOST = @SUBHOST
									)
							) AS b ON a.RPR_ID_HOST = HostID AND a.RPR_DISTR = b.DistrNumber AND a.RPR_COMP = b.CompNumber
						INNER JOIN dbo.Hosts c ON a.RPR_ID_HOST = c.HostID
					WHERE RPR_DATE >= dbo.DateOf(DATEADD(MONTH, -1, GETDATE()))
					FOR XML PATH('item'), ROOT('prot')
				), '')

			SET @DATA = @DATA + ISNULL(
				(
					SELECT
						--HostReg AS '@HOST', RPR_DISTR AS '@DISTR', RPR_COMP AS '@COMP', CONVERT(VARCHAR(20), RPR_DATE, 120) AS '@DATE',
						--RPR_OPER AS '@OPER', RPR_REG AS '@REG', RPR_TYPE AS '@TYPE', RPR_TEXT AS '@TEXT', RPR_USER AS '@USER', RPR_COMPUTER AS '@COMPUTER'
						--*
						SystemBaseName AS '@SYS', CONVERT(VARCHAR(20), b.START, 112) AS '@DATE',
						PRICE AS '@PRICE'
					FROM
						Price.SystemPrice a
						INNER JOIN Common.Period b ON a.ID_MONTH = b.ID
						INNER JOIN dbo.SystemTable c ON c.SystemID = a.ID_SYSTEM
					WHERE START >= dbo.DateOf(DATEADD(MONTH, -6, GETDATE()))
					FOR XML PATH('item'), ROOT('price')
				), '')

			SET @DATA = @DATA +
				ISNULL((
					SELECT
						SystemBaseName AS '@SYS', DistrNumber AS '@DISTR', CompNumber AS '@COMP',
						CONVERT(VARCHAR(64), DATE, 120) AS '@DATE'
					FROM
						(
							SELECT SystemName, DistrNumber, CompNumber
							FROM
								dbo.RegNodeTable
							WHERE Comment LIKE @SH_REG OR Comment LIKE @SH_REG_ADD

							UNION

							SELECT a.SystemName, DistrNumber, CompNumber
							FROM
								dbo.RegNodeTable a
								INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
								INNER JOIN dbo.SubhostComplect c ON SC_DISTR = DistrNumber AND SC_COMP = CompNumber AND c.SC_ID_HOST = b.HostID
							WHERE SystemReg = 1 AND SC_REG = 1 AND SC_ID_SUBHOST = @SUBHOST

							UNION

							SELECT SystemName, DistrNumber, CompNumber
							FROM dbo.RegNodeTable a
							WHERE Complect IN
								(
									SELECT Complect
									FROM
										dbo.RegNodeTable a
										INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
										INNER JOIN dbo.SubhostComplect c ON SC_DISTR = DistrNumber AND SC_COMP = CompNumber AND c.SC_ID_HOST = b.HostID
									WHERE SystemReg = 1 AND SC_REG = 1 AND SC_ID_SUBHOST = @SUBHOST
								)
						) AS o_O
						INNER JOIN dbo.SystemTable a ON a.SystemBaseName = o_O.SystemName
						INNER JOIN dbo.BLACK_LIST_REG b ON b.ID_SYS = a.SystemID AND o_O.DistrNumber = b.DISTR AND o_O.CompNumber = b.COMP
					WHERE P_DELETE = 0

					FOR XML PATH('item'), ROOT('black')
				), '')

			SET @DATA = @DATA +
				ISNULL((
					SELECT
						HostReg AS '@HOST', DistrNumber AS '@DISTR', CompNumber AS '@COMP',
						CONVERT(VARCHAR(64), SET_DATE, 120) AS '@DATE'
					FROM
						(
							SELECT SystemName, DistrNumber, CompNumber
							FROM
								dbo.RegNodeTable
							WHERE Comment LIKE @SH_REG OR Comment LIKE @SH_REG_ADD

							UNION

							SELECT a.SystemName, DistrNumber, CompNumber
							FROM
								dbo.RegNodeTable a
								INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
								INNER JOIN dbo.SubhostComplect c ON SC_DISTR = DistrNumber AND SC_COMP = CompNumber AND c.SC_ID_HOST = b.HostID
							WHERE SystemReg = 1 AND SC_REG = 1 AND SC_ID_SUBHOST = @SUBHOST

							UNION

							SELECT SystemName, DistrNumber, CompNumber
							FROM dbo.RegNodeTable a
							WHERE Complect IN
								(
									SELECT Complect
									FROM
										dbo.RegNodeTable a
										INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
										INNER JOIN dbo.SubhostComplect c ON SC_DISTR = DistrNumber AND SC_COMP = CompNumber AND c.SC_ID_HOST = b.HostID
									WHERE SystemReg = 1 AND SC_REG = 1 AND SC_ID_SUBHOST = @SUBHOST
								)
						) AS o_O
						INNER JOIN dbo.SystemTable a ON a.SystemBaseName = o_O.SystemName
						INNER JOIN dbo.ExpertDistr b ON b.ID_HOST = a.HostID AND o_O.DistrNumber = b.DISTR AND o_O.CompNumber = b.COMP
						INNER JOIN dbo.Hosts c ON c.HostID = a.HostID
					WHERE UNSET_DATE IS NULL

					FOR XML PATH('item'), ROOT('expert')
				), '')

			SET @DATA = @DATA +
				ISNULL((
					SELECT
						HostReg AS '@HOST', DistrNumber AS '@DISTR', CompNumber AS '@COMP',
						CONVERT(VARCHAR(64), SET_DATE, 120) AS '@DATE'
					FROM
						(
							SELECT SystemName, DistrNumber, CompNumber
							FROM
								dbo.RegNodeTable
							WHERE Comment LIKE @SH_REG OR Comment LIKE @SH_REG_ADD

							UNION

							SELECT a.SystemName, DistrNumber, CompNumber
							FROM
								dbo.RegNodeTable a
								INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
								INNER JOIN dbo.SubhostComplect c ON SC_DISTR = DistrNumber AND SC_COMP = CompNumber AND c.SC_ID_HOST = b.HostID
							WHERE SystemReg = 1 AND SC_REG = 1 AND SC_ID_SUBHOST = @SUBHOST

							UNION

							SELECT SystemName, DistrNumber, CompNumber
							FROM dbo.RegNodeTable a
							WHERE Complect IN
								(
									SELECT Complect
									FROM
										dbo.RegNodeTable a
										INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
										INNER JOIN dbo.SubhostComplect c ON SC_DISTR = DistrNumber AND SC_COMP = CompNumber AND c.SC_ID_HOST = b.HostID
									WHERE SystemReg = 1 AND SC_REG = 1 AND SC_ID_SUBHOST = @SUBHOST
								)
						) AS o_O
						INNER JOIN dbo.SystemTable a ON a.SystemBaseName = o_O.SystemName
						INNER JOIN dbo.HotlineDistr b ON b.ID_HOST = a.HostID AND o_O.DistrNumber = b.DISTR AND o_O.CompNumber = b.COMP
						INNER JOIN dbo.Hosts c ON c.HostID = a.HostID
					WHERE UNSET_DATE IS NULL

					FOR XML PATH('item'), ROOT('hotline')
				), '')

			SELECT CONVERT(VARCHAR(MAX), CASE @ENC WHEN 1 THEN '<?xml version="1.0" encoding="windows-1251"?>' ELSE '' END + '<root>') + CONVERT(VARCHAR(MAX), CAST(@DATA AS XML)) + CONVERT(VARCHAR(MAX), '</root>') AS DATA


		END

		IF @TYPE <> 'ALL'
			SELECT CONVERT(VARCHAR(MAX), CASE @ENC WHEN 1 THEN '<?xml version="1.0" encoding="windows-1251"?>' ELSE '' END) + CONVERT(VARCHAR(MAX), CAST(@DATA AS XML)) AS DATA

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
