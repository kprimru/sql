USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[Company]
(
        [ID]                UniqueIdentifier      NOT NULL,
        [ID_MASTER]         UniqueIdentifier          NULL,
        [SHORT]             NVarChar(256)             NULL,
        [NAME]              NVarChar(896)         NOT NULL,
        [NUMBER]            Int                       NULL,
        [ID_PAY_CAT]        UniqueIdentifier          NULL,
        [ID_WORK_STATE]     UniqueIdentifier          NULL,
        [ID_POTENTIAL]      UniqueIdentifier          NULL,
        [ID_ACTIVITY]       UniqueIdentifier          NULL,
        [ACTIVITY_NOTE]     NVarChar(Max)             NULL,
        [ID_SENDER]         UniqueIdentifier          NULL,
        [SENDER_NOTE]       NVarChar(Max)             NULL,
        [ID_NEXT_MON]       UniqueIdentifier          NULL,
        [WORK_DATE]         SmallDateTime             NULL,
        [DELETE_COMMENT]    NVarChar(512)             NULL,
        [ID_AVAILABILITY]   UniqueIdentifier          NULL,
        [ID_TAXING]         UniqueIdentifier          NULL,
        [ID_WORK_STATUS]    UniqueIdentifier          NULL,
        [ID_CHARACTER]      UniqueIdentifier          NULL,
        [ID_REMOTE]         UniqueIdentifier          NULL,
        [EMAIL]             NVarChar(1024)            NULL,
        [BLACK_LIST]        Bit                       NULL,
        [BLACK_NOTE]        NVarChar(Max)             NULL,
        [STATUS]            TinyInt               NOT NULL,
        [BDATE]             DateTime              NOT NULL,
        [EDATE]             DateTime                  NULL,
        [OLD_ID]            UniqueIdentifier          NULL,
        [UPD_USER]          NVarChar(256)         NOT NULL,
        [WORK_BEGIN]        SmallDateTime             NULL,
        [CARD]              TinyInt                   NULL,
        [PAPER_CARD]        Bit                       NULL,
        [ID_PROJECT]        UniqueIdentifier          NULL,
        [DEPO_NUM]          Int                       NULL,
        [DEPO]              Bit                       NULL,
        CONSTRAINT [PK_Client.Company] PRIMARY KEY NONCLUSTERED ([ID]),
        CONSTRAINT [FK_Client.Company(ID_MASTER)_Client.Company(ID)] FOREIGN KEY  ([ID_MASTER]) REFERENCES [Client].[Company] ([ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_Client.Company(ID)] ON [Client].[Company] ([ID] ASC);
CREATE NONCLUSTERED INDEX [IX_Client.Company(CARD)+(ID,STATUS)] ON [Client].[Company] ([CARD] ASC) INCLUDE ([ID], [STATUS]);
CREATE NONCLUSTERED INDEX [IX_Client.Company(EMAIL,ID,STATUS)] ON [Client].[Company] ([EMAIL] ASC, [ID] ASC, [STATUS] ASC);
CREATE NONCLUSTERED INDEX [IX_Client.Company(ID_ACTIVITY,STATUS)+(ID)] ON [Client].[Company] ([ID_ACTIVITY] ASC, [STATUS] ASC) INCLUDE ([ID]);
CREATE NONCLUSTERED INDEX [IX_Client.Company(ID_AVAILABILITY,STATUS)+(ID)] ON [Client].[Company] ([ID_AVAILABILITY] ASC, [STATUS] ASC) INCLUDE ([ID]);
CREATE NONCLUSTERED INDEX [IX_Client.Company(ID_CHARACTER,STATUS)+(ID)] ON [Client].[Company] ([ID_CHARACTER] ASC, [STATUS] ASC) INCLUDE ([ID]);
CREATE NONCLUSTERED INDEX [IX_Client.Company(ID_MASTER,BDATE)+(ID_AVAILABILITY)] ON [Client].[Company] ([ID_MASTER] ASC, [BDATE] ASC) INCLUDE ([ID_AVAILABILITY]);
CREATE NONCLUSTERED INDEX [IX_Client.Company(ID_MASTER,UPD_USER,BDATE)] ON [Client].[Company] ([ID_MASTER] ASC, [UPD_USER] ASC, [BDATE] ASC);
CREATE NONCLUSTERED INDEX [IX_Client.Company(ID_NEXT_MON,STATUS)+(ID)] ON [Client].[Company] ([ID_NEXT_MON] ASC, [STATUS] ASC) INCLUDE ([ID]);
CREATE NONCLUSTERED INDEX [IX_Client.Company(ID_PAY_CAT,STATUS)+(ID)] ON [Client].[Company] ([ID_PAY_CAT] ASC, [STATUS] ASC) INCLUDE ([ID]);
CREATE NONCLUSTERED INDEX [IX_Client.Company(ID_POTENTIAL,STATUS)+(ID)] ON [Client].[Company] ([ID_POTENTIAL] ASC, [STATUS] ASC) INCLUDE ([ID]);
CREATE NONCLUSTERED INDEX [IX_Client.Company(ID_REMOTE,STATUS)+(ID)] ON [Client].[Company] ([ID_REMOTE] ASC, [STATUS] ASC) INCLUDE ([ID]);
CREATE NONCLUSTERED INDEX [IX_Client.Company(ID_SENDER,STATUS)+(ID)] ON [Client].[Company] ([ID_SENDER] ASC, [STATUS] ASC) INCLUDE ([ID]);
CREATE NONCLUSTERED INDEX [IX_Client.Company(ID_WORK_STATE,STATUS)+(ID)] ON [Client].[Company] ([ID_WORK_STATE] ASC, [STATUS] ASC) INCLUDE ([ID]);
CREATE NONCLUSTERED INDEX [IX_Client.Company(NAME,STATUS)+(ID)] ON [Client].[Company] ([NAME] ASC, [STATUS] ASC) INCLUDE ([ID]);
CREATE NONCLUSTERED INDEX [IX_Client.Company(NUMBER,STATUS)+(ID)] ON [Client].[Company] ([NUMBER] ASC, [STATUS] ASC) INCLUDE ([ID]);
CREATE NONCLUSTERED INDEX [IX_Client.Company(STATUS)+(ID)] ON [Client].[Company] ([STATUS] ASC) INCLUDE ([ID]);
CREATE NONCLUSTERED INDEX [IX_Client.Company(STATUS)+(ID,NAME)] ON [Client].[Company] ([STATUS] ASC) INCLUDE ([ID], [NAME]);
CREATE NONCLUSTERED INDEX [IX_Client.Company(STATUS)+(ID,WORK_DATE)] ON [Client].[Company] ([STATUS] ASC) INCLUDE ([ID], [WORK_DATE]);
CREATE NONCLUSTERED INDEX [IX_Client.Company(STATUS,CARD)+(ID)] ON [Client].[Company] ([STATUS] ASC, [CARD] ASC) INCLUDE ([ID]);
CREATE UNIQUE NONCLUSTERED INDEX [UX_Client.Company(ID)+(NAME)] ON [Client].[Company] ([ID] ASC) INCLUDE ([NAME]);
GO
