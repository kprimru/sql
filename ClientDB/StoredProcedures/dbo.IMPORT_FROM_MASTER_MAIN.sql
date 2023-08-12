USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[IMPORT_FROM_MASTER_MAIN]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[IMPORT_FROM_MASTER_MAIN]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[IMPORT_FROM_MASTER_MAIN]
AS
BEGIN
	SET NOCOUNT ON;

        DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER);
	    DECLARE @Query          NVarChar(Max);
        DECLARE @SubhostName    VarChar(10);
        DECLARE @DUTY Int;

        DECLARE @Distr Table
		(
		    -- HostID - из ALPHA!
			HostID	SmallInt	    NOT NULL,
			HostReg	VarChar(100)    NOT NULL,
			Distr	Int			    NOT NULL,
			Comp	TinyInt		    NOT NULL,
			Primary Key Clustered(Distr, HostID, Comp)
		);

        SELECT @DUTY = DutyID
		FROM dbo.DutyTable
		WHERE DutyName = 'Автомат'

		IF @DUTY IS NULL
		BEGIN
			RAISERROR('Отсутствует встроенный сотрудник ДС! Импорт невозможен', 16, 1)
			RETURN
		END

        SET @SubhostName = Cast([System].[Setting@Get]('SUBHOST_NAME') AS VarChar(128));


        SET @Query = 'SELECT HostID, HostReg, DistrNumber, CompNumber FROM OPENQUERY([PC275-SQL\ALPHA], ''SELECT * FROM ClientDB.dbo.SubhostDistrs@Get(NULL, ''''' + @SubhostName + ''''');'');';

        INSERT INTO @Distr(HostID, HostReg, Distr, Comp)
        EXEC (@Query)


        -- обновляем список дистрибутивов подключенных к ЗВЭ
		TRUNCATE TABLE dbo.ExpertDistr;

		-- обновляем списко дистрибутивов подключенных к чату

		TRUNCATE TABLE dbo.HotlineDistr;

		-- Обновляем черный список ИП

		TRUNCATE TABLE dbo.BLACK_LIST_REG;

		INSERT INTO dbo.BLACK_LIST_REG(ID_SYS, DISTR, COMP, DATE, P_DELETE)
		SELECT S.SystemID, B.Distr, B.Comp, B.Date, 0
		FROM @Distr AS D
		INNER JOIN dbo.Hosts AS H ON H.HostReg = D.HostReg
		INNER JOIN dbo.SystemTable S ON S.HostID = H.HostID
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].dbo.BLACK_LIST_REG AS B ON B.ID_SYS = S.SystemID AND B.DISTR = D.Distr AND B.COMP = D.Comp
		WHERE B.P_DELETE = 0;

		-- Обновляем протокол РЦ

		INSERT INTO dbo.RegProtocol(RPR_DATE, RPR_ID_HOST, RPR_DISTR, RPR_COMP, RPR_OPER, RPR_REG, RPR_TYPE, RPR_TEXT, RPR_USER, RPR_COMPUTER)
		SELECT RPR_DATE, H.HostID, RPR_DISTR, RPR_COMP, RPR_OPER, RPR_REG, RPR_TYPE, RPR_TEXT, RPR_USER, RPR_COMPUTER
		FROM @Distr AS D
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[RegProtocol] AS P ON D.HostID = P.RPR_ID_HOST AND D.Distr = P.RPR_DISTR AND D.Comp = P.RPR_COMP
		INNER JOIN dbo.Hosts H ON H.HostReg = D.HostReg
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.RegProtocol R
				WHERE R.RPR_ID_HOST = H.HostID
					AND R.RPR_DISTR = P.RPR_DISTR
					AND R.RPR_COMP = P.RPR_COMP
					AND R.RPR_DATE = P.RPR_DATE
					AND R.RPR_TEXT = P.RPR_TEXT
					AND R.RPR_OPER = P.RPR_OPER
					AND R.RPR_TYPE = P.RPR_TYPE
			);

			-- Обновляем РЦ

		DELETE FROM dbo.RegNodeTable;

		INSERT INTO dbo.RegNodeTable(
					SystemName, DistrNumber, CompNumber, DistrType, TechnolType, NetCount, SubHost, TransferCount, TransferLeft,
					Service, RegisterDate, Comment, Complect, ODOn, ODOff
					)
		SELECT
			R.SystemName, DistrNumber, CompNumber, DistrType, TechnolType, NetCount, SubHost, TransferCount, TransferLeft,
			Service, RegisterDate, Comment, Complect, ODOn, ODOff
		FROM @Distr AS D
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[SystemTable] AS S ON D.HostID = S.HostID
		INNER JOIN [PC275-SQL\ALPHA].[ClientDB].[dbo].[RegNodeTable] AS R ON R.[SystemName] = S.SystemBaseName AND R.DistrNumber = D.DIstr AND R.CompNumber = D.Comp;

		--/*--
		INSERT INTO dbo.HotlineChat(SYS, DISTR, COMP, FIRST_DATE, START, FINISH, PROFILE, FIO, EMAIL, PHONE, CHAT, LGN, RIC_PERSONAL, LINKS)
		SELECT AC.SYS, AC.DISTR, AC.COMP, AC.FIRST_DATE, AC.START, AC.FINISH, AC.PROFILE, AC.FIO, AC.EMAIL, AC.PHONE, AC.CHAT, AC.LGN, AC.RIC_PERSONAL, AC.LINKS
		FROM [PC275-SQL\ALPHA].[ClientDB].[dbo].[HotlineChat] AS AC
		WHERE EXISTS
		    (
		        SELECT *
		        FROM @Distr AS D
		        INNER JOIN dbo.Hosts AS H ON D.HostReg = H.HostReg
		        INNER JOIN dbo.SystemTable AS S ON S.HostID = H.HostID
		        WHERE AC.SYS = S.SystemNumber
		            AND AC.DISTR = D.Distr
		            AND AC.COMP = D.Comp
		    )
		    AND NOT EXISTS
		    (
		        SELECT *
		        FROM dbo.HotlineChat AS C
		        WHERE   C.SYS = AC.SYS
		            AND C.DISTR = AC.DISTR
		            AND C.COMP = AC.COMP
		            AND IsNull(C.START, '20000101') = IsNull(AC.START, '20000101')
		            AND C.FIRST_DATE = AC.FIRST_DATE
		            AND C.FINISH = AC.FINISH
		            AND C.PROFILE = AC.PROFILE
		            AND C.FIO = AC.FIO
		            AND C.EMAIL = AC.EMAIL
		            AND C.PHONE = AC.PHONE
		            AND C.CHAT = AC.CHAT
		            AND C.LGN = AC.LGN
		            AND C.RIC_PERSONAL = AC.RIC_PERSONAL
		            AND IsNull(C.LINKS, '') = IsNull(AC.LINKS, '')
		    )
		OPTION (FORCE ORDER);
		--*/--

		INSERT INTO dbo.ClientDutyQuestion(SYS, DISTR, COMP, DATE, FIO, EMAIL, PHONE, QUEST)
		OUTPUT inserted.ID INTO @TBL
		SELECT SYS, DISTR, COMP, DATE, FIO, EMAIL, PHONE, QUEST
		FROM [PC275-SQL\ALPHA].[ClientDB].[dbo].[ClientDutyQuestion] AS AC
		WHERE EXISTS
		    (
		        SELECT *
		        FROM @Distr AS D
		        INNER JOIN dbo.Hosts AS H ON D.HostReg = H.HostReg
		        INNER JOIN dbo.SystemTable AS S ON S.HostID = H.HostID
		        WHERE AC.SYS = S.SystemNumber
		            AND AC.DISTR = D.Distr
		            AND AC.COMP = D.Comp
		    )
		    AND NOT EXISTS
			(
				SELECT *
				FROM dbo.ClientDutyQuestion C
				WHERE   C.SYS = AC.SYS
					AND C.DISTR = AC.DISTR
					AND C.COMP = AC.COMP
					AND Cast(C.DATE AS SmallDateTime) = Cast(AC.DATE AS SmallDateTime)
					AND C.FIO = AC.FIO
					AND C.EMAIL = AC.EMAIL
					AND C.PHONE = AC.PHONE
					AND C.QUEST = AC.QUEST
			)
		OPTION (FORCE ORDER);

		INSERT INTO dbo.ClientDutyTable(
			ClientID, ClientDutyDateTime, ClientDutySurname, ClientDutyPhone, DutyID, ClientDutyQuest, EMAIL,
			ClientDutyNPO, ClientDutyPos, ClientDutyComplete, ClientDutyComment, ID_DIRECTION)
		SELECT
			ID_CLIENT, a.DATE, a.FIO, a.PHONE, @DUTY, a.QUEST, a.EMAIL, 0, '', 0, '',
			(
				SELECT TOP 1 ID
				FROM dbo.CallDirection
				WHERE NAME = 'ВопросЭксперту'
			)
		FROM @TBL z
		INNER JOIN dbo.ClientDutyQuestion a ON a.ID = z.ID
		INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.DISTR = b.DISTR AND a.COMP = b.COMP
		INNER JOIN dbo.SystemTable c ON b.HostID = c.HostID AND c.SystemNumber = a.SYS
		WHERE a.IMPORT IS NULL;

		UPDATE dbo.ClientDutyQuestion
		SET IMPORT = GETDATE()
		WHERE ID IN (SELECT ID FROM @TBL);
END

GO
