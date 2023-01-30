TRUNCATE TABLE [CodyMappingTraining].[dst].[Mastname]
GO

DECLARE @states TABLE
(
	 State_Name VARCHAR(30)
	,State_Code CHAR(3)
)

INSERT INTO @states 
(
	 State_Code
	,State_Name
)
VALUES
('AL', 'Alabama'),
('AK', 'Alaska'),
('AZ', 'Arizona'),
('AR', 'Arkansas'),
('CA', 'California'),
('CO', 'Colorado'),
('CT', 'Connecticut'),
('DE', 'Delaware'),
('DC', 'District of Columbia'),
('FL', 'Florida'),
('GA', 'Georgia'),
('HI', 'Hawaii'),
('ID', 'Idaho'),
('IL', 'Illinois'),
('IN', 'Indiana'),
('IA', 'Iowa'),
('KS', 'Kansas'),
('KY', 'Kentucky'),
('LA', 'Louisiana'),
('ME', 'Maine'),
('MD', 'Maryland'),
('MA', 'Massachusetts'),
('MI', 'Michigan'),
('MN', 'Minnesota'),
('MS', 'Mississippi'),
('MO', 'Missouri'),
('MT', 'Montana'),
('NE', 'Nebraska'),
('NV', 'Nevada'),
('NH', 'New Hampshire'),
('NJ', 'New Jersey'),
('NM', 'New Mexico'),
('NY', 'New York'),
('NC', 'North Carolina'),
('ND', 'North Dakota'),
('OH', 'Ohio'),
('OK', 'Oklahoma'),
('OR', 'Oregon'),
('PA', 'Pennsylvania'),
('RI', 'Rhode Island'),
('SC', 'South Carolina'),
('SD', 'South Dakota'),
('TN', 'Tennessee'),
('TX', 'Texas'),
('UT', 'Utah'),
('VT', 'Vermont'),
('VA', 'Virginia'),
('WA', 'Washington'),
('WV', 'West Virginia'),
('WI', 'Wisconsin'),
('WY', 'Wyoming')


SELECT 
	 *
	,ROW_NUMBER() OVER(PARTITION BY PersonID ORDER BY AsOfDate DESC) AS Row_NO
INTO #ppft
FROM [CodyMappingTraining].[src].[PersonPhysicalFeatureTable]
CREATE INDEX idx_PPFTPersonID ON #ppft(PersonID)


DECLARE @phone_Types TABLE
(
	 Type_ID INT
	,Phone_Type VARCHAR(10)
)

INSERT INTO @phone_Types
	SELECT ROW_Number() OVER(ORDER BY a.Phone_Type) AS Type_ID, a.Phone_Type
	FROM 
	(
		SELECT DISTINCT Type AS Phone_Type
		FROM [CodyMappingTraining].[src].[Phone]
	) a

	--SELECT * FROM @phone_Types


SELECT
	 a.PersonID
	,CASE
		WHEN a.Type_ID = 1 THEN TRIM(REPLACE(LEFT(a.PhoneNumber, CHARINDEX( 'x', a.PhoneNumber)), 'x', ''))
		ELSE ''
	  END AS Phone1
	,CASE
		WHEN a.Type_ID = 1 THEN
			CASE
				WHEN CHARINDEX('x', TRIM(a.PhoneNumber)) = 0 THEN ''
				ELSE RIGHT(TRIM(a.PhoneNumber), LEN(a.PhoneNumber) - CHARINDEX('x', TRIM(a.PhoneNumber)))
			 END 
		ELSE ''
	  END AS Phone1_Extension
	,CASE
		WHEN a.Type_ID = 2 THEN TRIM(REPLACE(LEFT(b.PhoneNumber, CHARINDEX( 'x', b.PhoneNumber)), 'x', ''))
		ELSE ''
	  END AS Phone2
	,CASE
		WHEN a.Type_ID = 2 THEN
			CASE
				WHEN CHARINDEX('x', TRIM(b.PhoneNumber)) = 0 THEN ''
				ELSE RIGHT(TRIM(b.PhoneNumber), LEN(b.PhoneNumber) - CHARINDEX('x', TRIM(b.PhoneNumber)))
		END
		ELSE ''
	 END AS Phone2_Extension
	,CASE
		WHEN a.Type_ID = 3 THEN TRIM(REPLACE(LEFT(c.PhoneNumber, CHARINDEX( 'x', c.PhoneNumber)), 'x', ''))
		ELSE ''
	  END AS Phone3
	,CASE
		WHEN a.Type_ID = 3 THEN
			CASE
				WHEN CHARINDEX('x', TRIM(c.PhoneNumber)) = 0 THEN ''
				ELSE RIGHT(TRIM(c.PhoneNumber), LEN(c.PhoneNumber) - CHARINDEX('x', TRIM(c.PhoneNumber)))
			END
		ELSE ''
	 END AS Phone3_Extension
INTO #phones
FROM
(
	SELECT a1.*
	FROM
	(
		SELECT 
			 p.*
			,ROW_NUMBER() OVER(PARTITION BY PersonID ORDER BY Type) AS Row_NO
			,pt.Type_ID
		FROM [src].[Phone] p
		INNER JOIN @phone_Types pt ON pt.Phone_Type = p.Type
	) a1
	WHERE a1.Row_NO = 1
) a
LEFT OUTER JOIN
(
	SELECT b1.*
	FROM
	(
		SELECT 
			 p.*
			,pt.Type_ID
		FROM [src].[Phone] p
		INNER JOIN @phone_Types pt ON pt.Phone_Type = p.Type
		WHERE pt.Type_ID = 2
	) b1
) b ON a.PersonId = b.PersonId
LEFT OUTER JOIN
(
	SELECT c1.*
	FROM
	(
		SELECT 
			 p.*
			,pt.Type_ID
		FROM [src].[Phone] p
		INNER JOIN @phone_Types pt ON pt.Phone_Type = p.Type
		WHERE pt.Type_ID = 3
	) c1
) c ON a.PersonId = c.PersonId
order by a.PersonId

CREATE INDEX idx_PhonePersonID ON #phones(PersonID)


INSERT INTO [CodyMappingTraining].[dst].[Mastname]
(
	 [Recnum]
    ,[FName]
    ,[MName]
    ,[LName]
    ,[Suffix]
    ,[Age]
    ,[House]
    ,[Street]
    ,[City]
    ,[State]
    ,[Zip]
    ,[ZipExtension]
    ,[Height]
    ,[Weight]
    ,[Ethnicity_Code]
    ,[Ethnicity_Desc]
    ,[Race_Code]
    ,[Race_Desc]
    ,[Build_Code]
    ,[Build_Desc]
    ,[Complexion_Code]
    ,[Complexion_Desc]
    ,[EyeColor_Code]
    ,[EyeColor_Desc]
    ,[Sex_Code]
    ,[Sex_Desc]
    ,[HairColor_Code]
    ,[HairColor_Desc]
    ,[SSN]
    ,[DRLic]
    ,[DRLic_StateCode]
    ,[DRLic_StateDesc]
    ,[Passport]
    ,[Phone1]
    ,[Phone1_Extension]
    ,[Phone2]
    ,[Phone2_Extension]
    ,[Phone3]
    ,[Phone3_Extension]
)
SELECT
	 ROW_NUMBER() OVER(ORDER BY x.ID) AS Recnum
	,x.FirstName AS FName
	,x.MiddleName AS MName
	,x.LastName AS LName
	,x.NameSufx AS Suffix
	,x.Age
	,x.House
	,x.Street
	,x.City
	,x.State
	,x.Zip
	,ISNULL(x.ZipExtension, '') AS ZipExtension
	,x.Person_Height AS Height
	,x.Person_Weight AS 'Weight'
	,x.Person_Ethnicity_Code AS Ethnicity_Code
	,x.Person_Ethnicity_Description AS Ethnicity_Desc
	,x.Person_Race AS Race_Code
	,x.Person_Race_Description AS Race_Desc
	,LEFT(x.Person_Build, 6) AS Build_Code
	,LEFT(x.Person_Build_Description, 50) AS Build_Desc
	,x.Person_Complexion AS Complexion_Code
	,x.Person_Complexion_Description Complexion_Desc
	,x.Person_Eye_Color_Code AS EyeColor_Code
	,x.Person_Eye_Color_Description AS EyeColor_Desc
	,x.Person_Gender AS Sex_Code
	,x.Person_Gender_Description
	,x.Person_Hair_Code AS Hair_Color_Code
	,x.Person_Hair_Description AS HairColor_Desc
	,x.SSN AS SSN
	,x.DriversLicense AS DRLic
	,x.State_Code AS DRLic_StateCode
	,x.DriversLicenseState AS DRLic_StateDesc
	,x.Passport
	,x.Phone1
	,x.Phone1_Extension
	,x.Phone2
	,x.Phone2_Extension
	,x.Phone3
	,x.Phone3_Extension
FROM
(
	SELECT 
		pt.ID
		,pt.[FirstName]
		,pt.[LastName]
		,ISNULL(pt.[Age], '') AS Age
		,LEFT(pt.Street, CHARINDEX(' ', pt.Street)) AS House
		,TRIM(REPLACE(pt.Street, LEFT(pt.Street, CHARINDEX(' ', pt.Street)), '')) AS Street
		,pt.[City]
		,pt.[State]
		--,pt.[Zip]
		,LEFT(pt.Zip, 5) AS Zip
		,CASE
		WHEN REPLACE(pt.Zip, LEFT(Zip, 6) , '') = '' THEN NULL
		ELSE CAST(REPLACE(pt.Zip, LEFT(pt.Zip, 6) , '') AS INT) 
		END AS ZipExtension
		,ISNULL(pt.[MiddleName], '') AS MiddleName
		,ISNULL(pt.[NameSufx], '') AS NameSufx
		,pt.[IsFlagged]
		,pit.[SSN]
		,pit.[DriversLicense]
		,pit.[Passport]
		,st.State_Code
		,pit.[DriversLicenseState]
		,ISNULL(ppft.Height, '') AS Person_Height
		,ISNULL(ppft.Weight, '') AS Person_Weight
		,ph.Phone1
		,ph.Phone1_Extension
		,ph.Phone2
		,ph.Phone2_Extension
		,ph.Phone3
		,ph.Phone3_Extension
		,ISNULL(cs.Sex, '') AS Person_Gender
		,ISNULL(cs.Description, '') AS Person_Gender_Description
		,ISNULL(cr.Race, '') AS Person_Race
		,ISNULL(cr.Description, '') AS Person_Race_Description
		,ISNULL(chc.Hair, '') AS Person_Hair_Code
		,ISNULL(chc.Description, '') AS Person_Hair_Description
		,ISNULL(cec.Eye, '') AS Person_Eye_Color_Code
		,ISNULL(cec.Description, '') AS Person_Eye_Color_Description
		,ISNULL(ce.Ethnicity, '') AS Person_Ethnicity_Code
		,ISNULL(ce.Description, '') AS Person_Ethnicity_Description
		,ISNULL(cc.[Complexion], '') AS Person_Complexion
		,ISNULL(cc.[Description], '') AS Person_Complexion_Description
		,ISNULL(cb.Build, '') AS Person_Build
		,ISNULL(cb.Description, '') AS Person_Build_Description
	FROM [CodyMappingTraining].[src].[PersonTable] pt
	LEFT OUTER JOIN [CodyMappingTraining].[src].[PersonIdentifierTable] pit ON pt.ID = pit.PersonId
	LEFT OUTER JOIN #ppft ppft ON pt.ID = ppft.PersonId
	LEFT OUTER JOIN [CodyMappingTraining].[src].[CodeSex] cs ON cs.ID = ppft.SexId
	LEFT OUTER JOIN #phones ph ON ph.PersonId = pt.Id
	LEFT OUTER JOIN [CodyMappingTraining].[src].[CodeRace] cr ON cr.Id = ppft.RaceId
	LEFT OUTER JOIN [CodyMappingTraining].[src].[CodeHairColor] chc ON chc.Id = ppft.HairColorId
	LEFT OUTER JOIN [CodyMappingTraining].[src].[CodeEyeColor] cec ON cec.ID = ppft.EyeColorId
	LEFT OUTER JOIN [CodyMappingTraining].[src].[CodeEthnicity] ce ON ce.ID = ppft.EthnicityId
	LEFT OUTER JOIN [CodyMappingTraining].[src].[CodeComplexion] cc ON cc.Id = ppft.ComplexionId
	LEFT OUTER JOIN [CodyMappingTraining].[src].[CodeBuild] cb ON cb.ID = ppft.BuildId
	LEFT OUTER JOIN @states st ON st.State_Name = pit.DriversLicenseState
	WHERE ppft.Row_No = 1
) x


DROP TABLE #ppft
DROP TABLE #phones


GO

